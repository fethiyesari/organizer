import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressGraphPage extends StatelessWidget {
  final List<Map<String, dynamic>> habits;

  const ProgressGraphPage({Key? key, required this.habits}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tamamlanma oranını hesapla
    int completedCount =
        habits.where((habit) => habit["completedToday"] == true).length;
    int remainingCount = habits.length - completedCount;

    // Grafik verisi oluştur
    final pieSections = [
      PieChartSectionData(
        color: Colors.green,
        value: completedCount.toDouble(),
        title: "$completedCount",
        titleStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 60,
      ),
      PieChartSectionData(
        color: Colors.red,
        value: remainingCount.toDouble(),
        title: "$remainingCount",
        titleStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 60,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("İlerleme Grafiği"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Günlük İlerleme Grafiği",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 4,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Tamamlanma Oranı: ${(completedCount / habits.length * 100).toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
