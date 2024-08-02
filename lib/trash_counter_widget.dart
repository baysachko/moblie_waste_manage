import 'package:flutter/material.dart';
import 'realtime_database_service.dart';
import 'your_data_model.dart';
import 'mapping.dart';

class TrashCounterWidget extends StatelessWidget {
  final RealtimeDatabaseService realtimeDatabaseService;

  TrashCounterWidget({required this.realtimeDatabaseService});

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
          List<YourDataModel> trashData = snapshot.data!['board3'] ?? [];
          int recyclableTrash = 0;
          int nonRecyclableTrash = 0;

          for (var data in trashData) {
            if (data.id == 'cam_motor_data_recyclable') {
              recyclableTrash = int.parse(data.value.toString());
            } else if (data.id == 'cam_motor_data_non_recyclable') {
              nonRecyclableTrash = int.parse(data.value.toString());
            }
          }

          return Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A2E), // Background color for the container
              border: Border.all(
                color: Color(0xFF16213E), // Border color
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  title: Text(
                    'Recyclable Trash Piece',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    recyclableTrash.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 202, 235, 103),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(color: Colors.grey[700]),
                ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  title: Text(
                    'Non Recyclable Trash Piece',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    nonRecyclableTrash.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 202, 235, 103),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
