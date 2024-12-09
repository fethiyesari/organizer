import 'package:flutter/material.dart';
import 'package:organizer/components/custom_drawer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        toolbarHeight: 80,
        backgroundColor: Colors.deepOrange,
      ),
      drawer: const CustomDrawer(),
    );
  }
}
