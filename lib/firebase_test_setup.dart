import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure this file is created using the Firebase CLI

Future<void> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
