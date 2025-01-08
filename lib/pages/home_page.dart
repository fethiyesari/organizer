import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:organizer/components/custom_drawer.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:organizer/services/google_calendar_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final googleCalendarService = GoogleCalendarService();
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

  final _googleSignIn = GoogleSignIn(
    scopes: [
      calendar.CalendarApi.calendarScope,
    ],
  );

  void _showAddTodoForm(BuildContext context) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _contentController = TextEditingController();
    DateTime? _selectedDate;
    TimeOfDay? _selectedTime;

    Future<void> _selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().toUtc(),
        firstDate: DateTime(2000).toUtc(),
        lastDate: DateTime(2100).toUtc(),
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
                decoration: const InputDecoration(labelText: "Task Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: "Task Description"),
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
                            ? "Select Date"
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
                            ? "Select Time"
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

                    await todosCollection.add({
                      'userId': user.uid,
                      'title': _titleController.text,
                      'content': _contentController.text,
                      'dueDate': dueDate.toIso8601String(),
                      'completed': false,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    // Google Calendar'a ekle
                    await googleCalendarService.addEventToGoogleCalendar(
                      _titleController.text,
                      _contentController.text,
                      DateTime.now(),
                      dueDate,
                    );

                    Navigator.pop(context);
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
      title: const Text("To-Do", style: TextStyle(color: Colors.black)),
      iconTheme: const IconThemeData(color: Colors.black),
      toolbarHeight: 80,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: () => FirebaseAuth.instance.signOut(),
        ),
      ],
    ),
    drawer: const CustomDrawer(),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Search tasks...",
              suffixIcon: const Icon(Icons.search),
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
                return const Center(child: Text("No tasks added yet."));
              }
              return ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Dismissible(
                    key: Key(todo.id),
                    onDismissed: (_) => _removeTodo(todo),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
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
                        children: [
                          ListTile(
                            title: Text("Task Description: ${todo['content']}"),
                          ),
                          ListTile(
                            title: Text("Due Date: ${todo['dueDate']}"),
                          ),
                        ],
                      ),
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
      child: const Icon(Icons.add, color: Colors.white,),
    ),
  );
}


}
