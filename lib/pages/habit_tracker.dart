import 'package:flutter/material.dart';
import 'package:organizer/pages/progress_graph_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({Key? key}) : super(key: key);

  @override
  State<HabitTrackerPage> createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> {
  late CollectionReference habitsRef;
  List<Map<String, dynamic>> habits = [];

  @override
  void initState() {
    super.initState();
    habitsRef = FirebaseFirestore.instance.collection('habits');
    _fetchHabits();
  }

  Future<void> _fetchHabits() async {
    try {
      final snapshot = await habitsRef.get();
      final data = snapshot.docs.map((doc) {
        return {
          "id": doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      setState(() {
        habits = data;
      });
    } catch (e) {
      // Hata yönetimi
      print("Error fetching habits: $e");
    }
  }

  void _showAddHabitForm() {
    final TextEditingController _habitNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Alışkanlık Ekle"),
          content: TextField(
            controller: _habitNameController,
            decoration: const InputDecoration(
              labelText: "Alışkanlık Adı",
              hintText: "Örn: Kitap Okumak",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_habitNameController.text.isNotEmpty) {
                  _addHabit(_habitNameController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Ekle"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addHabit(String name) async {
    try {
      await habitsRef.add({
        "name": name,
        "completedToday": false,
        "createdAt": DateTime.now().toIso8601String(),
        "progress": {},
      });
      _fetchHabits();
    } catch (e) {
      // Hata yönetimi
      print("Error adding habit: $e");
    }
  }

  void _deleteHabit(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Alışkanlık Sil"),
          content:
              const Text("Bu alışkanlığı silmek istediğinize emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                habitsRef.doc(id).delete().then((_) {
                  _fetchHabits();
                  Navigator.pop(context);
                }).catchError((e) {
                  // Hata yönetimi
                  print("Error deleting habit: $e");
                });
              },
              child: const Text("Sil"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Habit Tracker"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return Card(
                    child: ListTile(
                      title: Text(habit["name"]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: habit["completedToday"],
                            onChanged: (value) {
                              habitsRef.doc(habit["id"]).update({
                                "completedToday": value,
                              }).then((_) {
                                _fetchHabits();
                              }).catchError((e) {
                                // Hata yönetimi
                                print("Error updating habit: $e");
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteHabit(habit["id"]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressGraphPage(habits: habits),
                  ),
                );
              },
              child: const Text("İlerleme Grafiği Görüntüle"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitForm,
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
