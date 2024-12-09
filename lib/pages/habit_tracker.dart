import 'package:flutter/material.dart';
import 'package:organizer/components/custom_drawer.dart';

class HabitTracker extends StatelessWidget {
  const HabitTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Habit Tracker"),
        toolbarHeight: 80,
        backgroundColor: Colors.deepOrange,
      ),
      drawer: const CustomDrawer(),
    );
  }
}
