// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'realtime_database_service.dart';
import 'your_data_model.dart';
import 'mapping.dart';

class BinPercentageWidget extends StatelessWidget {
  final RealtimeDatabaseService realtimeDatabaseService;

  BinPercentageWidget({required this.realtimeDatabaseService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, List<YourDataModel>>>(
      stream: realtimeDatabaseService.getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No data available');
        } else {
          List<YourDataModel> binData = snapshot.data!['board1'] ?? [];
          double recyclable = 0;
          double nonRecyclable = 0;

          for (var data in binData) {
            if (data.id == 'sensor_recyclable') {
              recyclable = double.parse(data.value.toString());
            } else if (data.id == 'sensor_non_recyclable') {
              nonRecyclable = double.parse(data.value.toString());
            }
          }

          return Container(
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A2E), // Dark background color
              border: Border.all(
                color: Color(0xFF16213E), // Dark border color
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              children: [
                Text(
                  'Recyclable Bin Percentage',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255), // Text color
                  ),
                ),
                CircularPercentIndicator(
                  radius: 40.0,
                  lineWidth: 9.0,
                  percent: recyclable / 100,
                  center: Text(
                    "${recyclable.toStringAsFixed(1)}%",
                    style: TextStyle(
                        color: Color.fromARGB(
                            255, 202, 235, 103)), // Center text color
                  ),
                  progressColor: Colors.cyan, // Circular indicator color
                ),
                SizedBox(height: 20),
                Text(
                  'Non Recyclable Bin Percentage',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255), // Text color
                  ),
                ),
                CircularPercentIndicator(
                  radius: 40.0,
                  lineWidth: 9.0,
                  percent: nonRecyclable / 100,
                  center: Text(
                    "${nonRecyclable.toStringAsFixed(1)}%",
                    style: TextStyle(
                        color: Color.fromARGB(
                            255, 202, 235, 103)), // Center text color
                  ),
                  progressColor: Colors.cyan, // Circular indicator color
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
