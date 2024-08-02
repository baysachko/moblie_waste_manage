import 'package:firebase_database/firebase_database.dart';
import 'your_data_model.dart';

class RealtimeDatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Stream<Map<String, List<YourDataModel>>> getData() {
    print("Fetching data from Realtime Database...");
    return _dbRef.child('boards').onValue.map((event) {
      final data = event.snapshot.value as Map;
      final Map<String, List<YourDataModel>> boardsData = {};

      data.forEach((key, value) {
        final boardData = Map<String, dynamic>.from(value as Map);
        boardsData[key] = boardData.entries.map((entry) {
          return YourDataModel.fromMap({
            'id': entry.key,
            'value': entry.value,
          });
        }).toList();
      });

      return boardsData;
    });
  }

  // Add this new method
  Stream<DatabaseEvent> getDataStream() {
    return _dbRef.child('boards').onValue;
  }
}
