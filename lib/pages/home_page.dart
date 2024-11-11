import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _todoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _todos = [];
  String _searchQuery = '';

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void _addTodo() {
    if (_todoController.text.isNotEmpty) {
      setState(() {
        _todos.add({"task": _todoController.text, "completed": false});
        _todoController.clear();
      });
    }
  }

  void _toggleComplete(int index) {
    setState(() {
      _todos[index]["completed"] = !_todos[index]["completed"];
    });
  }

  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodos = _todos
        .where((todo) => todo["task"].toLowerCase().contains(_searchQuery))
        .toList();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.deepOrange,
        title: const Text(
          "Organize",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepOrange,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Ana Sayfa'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapatır
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Hakkında'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Arama Çubuğu
            TextField(
              controller: _searchController,
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Görevlerde ara...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Görev Ekleme
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      hintText: 'Yeni görev ekle',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTodo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Ekle',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Görev Listesi
            Expanded(
              child: filteredTodos.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredTodos.length,
                      itemBuilder: (context, index) {
                        final todo = filteredTodos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              todo["task"],
                              style: TextStyle(
                                fontSize: 18,
                                decoration: todo["completed"]
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            leading: Checkbox(
                              value: todo["completed"],
                              onChanged: (value) =>
                                  _toggleComplete(_todos.indexOf(todo)),
                              activeColor: Colors.deepOrange,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _removeTodo(_todos.indexOf(todo)),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'Görev bulunamadı.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Yeni sayfa örneği - Hakkında Sayfası
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkında'),
        backgroundColor: Colors.deepOrange,
      ),
      body: const Center(
        child: Text(
          'Bu uygulama bir organizatör uygulamasıdır.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

// Yeni sayfa örneği - Ayarlar Sayfası
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: Colors.deepOrange,
      ),
      body: const Center(
        child: Text(
          'Ayarlar sayfası',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
