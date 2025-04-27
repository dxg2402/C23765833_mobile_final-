// File: moon_phase_card.dart
import 'package:flutter/material.dart';

class MoonPhase extends StatelessWidget {
  final String day;
  final String date;
  final String phase;

  const MoonPhase({
    required this.day,
    required this.date,
    required this.phase,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(date, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 10),
            Text("Moon Phase: $phase", style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
