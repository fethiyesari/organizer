import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:organizer/components/custom_drawer.dart';
import 'package:organizer/services/google_calendar_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final CollectionReference todosCollection = FirebaseFirestore.instance.collection('todos');
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  final googleCalendarService = GoogleCalendarService();

  Future<void> _toggleComplete(DocumentSnapshot todo) async {
    await todosCollection.doc(todo.id).update({
      'completed': !todo['completed'],
    });
  }

  Future<void> _removeTodo(DocumentSnapshot todo) async {
    await todosCollection.doc(todo.id).delete();
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date); // Gün-Ay-Yıl formatında
  }

  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final formattedTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(formattedTime); // Saat:Dakika formatında
  }

  void _showAddTodoForm(BuildContext context) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _contentController = TextEditingController();
    DateTime? _startDate;
    TimeOfDay? _startTime;
    DateTime? _endDate;
    TimeOfDay? _endTime;

    Future<void> _selectStartDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          _startDate = picked;
        });
      }
    }

    Future<void> _selectStartTime() async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        setState(() {
          _startTime = picked;
        });
      }
    }

    Future<void> _selectEndDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          _endDate = picked;
        });
      }
    }

    Future<void> _selectEndTime() async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        setState(() {
          _endTime = picked;
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
                      onPressed: _selectStartDate,
                      icon: const Icon(Icons.calendar_today, color: Colors.grey),
                      label: Text(
                        _startDate == null
                            ? "Select Start Date"
                            : formatDate(_startDate!),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectStartTime,
                      icon: const Icon(Icons.access_time, color: Colors.grey),
                      label: Text(
                        _startTime == null
                            ? "Select Start Time"
                            : formatTime(_startTime!),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectEndDate,
                      icon: const Icon(Icons.calendar_today, color: Colors.grey),
                      label: Text(
                        _endDate == null
                            ? "Select End Date"
                            : formatDate(_endDate!),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectEndTime,
                      icon: const Icon(Icons.access_time, color: Colors.grey),
                      label: Text(
                        _endTime == null
                            ? "Select End Time"
                            : formatTime(_endTime!),
                        style: TextStyle(color: Colors.grey[700]),
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
                      _startDate != null &&
                      _startTime != null &&
                      _endDate != null &&
                      _endTime != null) {
                    final startDateTime = DateTime(
                      _startDate!.year,
                      _startDate!.month,
                      _startDate!.day,
                      _startTime!.hour,
                      _startTime!.minute,
                    );

                    final endDateTime = DateTime(
                      _endDate!.year,
                      _endDate!.month,
                      _endDate!.day,
                      _endTime!.hour,
                      _endTime!.minute,
                    );

                    await todosCollection.add({
                      'userId': user.uid,
                      'title': _titleController.text,
                      'content': _contentController.text,
                      'startDate': startDateTime.toIso8601String(),
                      'endDate': endDateTime.toIso8601String(),
                      'completed': false,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    await googleCalendarService.addEventToGoogleCalendar(
                      _titleController.text,
                      _contentController.text,
                      startDateTime,
                      endDateTime,
                      context,
                    );

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
                child: const Text("Add Task", style: TextStyle(color: Colors.white)),
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
                    final startDate = DateTime.parse(todo['startDate']);
                    final endDate = DateTime.parse(todo['endDate']);
                    final completed = todo['completed'];

                    return Dismissible(
                      key: Key(todo.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,  // İkonu sola hizalar
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ),
                      onDismissed: (direction) {
                        _removeTodo(todo);
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        elevation: 4.0,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          leading: Checkbox(
                            value: completed,
                            onChanged: (_) => _toggleComplete(todo),
                          ),
                          title: Text(
                            todo['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(todo['content']),
                              const SizedBox(height: 8.0),
                              Text("Start: ${formatDate(startDate)} at ${formatTime(TimeOfDay.fromDateTime(startDate))}"),
                              Text("End: ${formatDate(endDate)} at ${formatTime(TimeOfDay.fromDateTime(endDate))}"),
                            ],
                          ),
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
        onPressed: () => _showAddTodoForm(context),
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
