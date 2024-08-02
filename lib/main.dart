import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'realtime_database_service.dart';
import 'bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final RealtimeDatabaseService _realtimeDatabaseService =
      RealtimeDatabaseService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BottomNavBar(realtimeDatabaseService: _realtimeDatabaseService),
    );
  }
}
