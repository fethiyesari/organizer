import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizer/components/custom_drawer.dart';
import 'package:organizer/pages/habit_tracker.dart';
import 'package:organizer/pages/notes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final CollectionReference todosCollection =
      FirebaseFirestore.instance.collection('todos');
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // Görev Tamamlama Durumu Değiştirme
  Future<void> _toggleComplete(DocumentSnapshot todo) async {
    await todosCollection.doc(todo.id).update({
      'completed': !todo['completed'],
    });
  }

  // Görev Silme
  Future<void> _removeTodo(DocumentSnapshot todo) async {
    await todosCollection.doc(todo.id).delete();
  }

  void _showAddTodoForm(BuildContext context) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _contentController = TextEditingController();
    DateTime? _selectedDate;
    TimeOfDay? _selectedTime;

    Future<void> _selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          _selectedDate = picked;
        });
      }
    }

    Future<void> _selectTime() async {
      final TimeOfDay? picked =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (picked != null) {
        setState(() {
          _selectedTime = picked;
        });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Görev Başlığı"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: "Görev İçeriği"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _selectedDate == null
                            ? "Tarih Seç"
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        _selectedTime == null
                            ? "Saat Seç"
                            : _selectedTime!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (_titleController.text.isNotEmpty &&
                      _contentController.text.isNotEmpty &&
                      _selectedDate != null &&
                      _selectedTime != null) {
                    final dueDate = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );

                    try {
                      await todosCollection.add({
                        'userId': user.uid,
                        'title': _titleController.text,
                        'content': _contentController.text,
                        'dueDate': dueDate.toIso8601String(),
                        'completed': false,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      print("Error adding todo: $e");
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                child: const Text("Görev Ekle"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text("To-Do"),
        toolbarHeight: 80,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Görev ara...",
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: todosCollection
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final todos = snapshot.data!.docs
                    .where((todo) => todo['title']
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                    .toList();
                if (todos.isEmpty) {
                  return const Center(child: Text("Henüz görev eklenmedi."));
                }
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: ExpansionTile(
                        title: Text(
                          todo['title'],
                          style: TextStyle(
                            decoration: todo['completed']
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        leading: Checkbox(
                          value: todo['completed'],
                          onChanged: (_) => _toggleComplete(todo),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeTodo(todo),
                        ),
                        children: [
                          ListTile(
                            title: Text("Görev Tanımı: ${todo['content']}"),
                          ),
                          ListTile(
                            title: Text("Bitiş Tarihi: ${todo['dueDate']}"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () => _showAddTodoForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
