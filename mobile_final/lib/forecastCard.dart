import 'package:flutter/material.dart';

class ForecastCard extends StatelessWidget {
  final String day;
  final String date;
  final String condition;
  final String maxTemp;
  final String minTemp;

  const ForecastCard({
    required this.day,
    required this.date,
    required this.condition,
    required this.maxTemp,
    required this.minTemp,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text('$day, $date', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Condition: $condition'),
            Text('Max Temp: $maxTemp'),
            Text('Min Temp: $minTemp'),
          ],
        ),
      ),
    );
  }
}
