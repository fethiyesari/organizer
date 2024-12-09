import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final CollectionReference notesCollection =
      FirebaseFirestore.instance.collection('notes');

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _addNote() async {
    if (_titleController.text.isNotEmpty &&
        _contentController.text.isNotEmpty) {
      try {
        await notesCollection.add({
          'userId': user.uid,
          'title': _titleController.text,
          'content': _contentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _titleController.clear();
        _contentController.clear();
        Navigator.pop(context);
      } catch (e) {
        print("Error adding note: $e");
      }
    }
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Not Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Başlık'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'İçerik'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: _addNote,
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(DocumentSnapshot note) async {
    try {
      await notesCollection.doc(note.id).delete();
    } catch (e) {
      print("Error deleting note: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notlar'),
        toolbarHeight: 80,
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notesCollection
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!.docs;
          if (notes.isEmpty) {
            return const Center(child: Text('Henüz not eklenmedi.'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: ListTile(
                  title: Text(note['title']),
                  subtitle: Text(note['content']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNote(note),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
