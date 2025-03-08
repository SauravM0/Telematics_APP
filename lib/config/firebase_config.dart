import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          // Replace with your Firebase configuration values from google-services.json
          apiKey: 'api',
          appId: '000',
          messagingSenderId: '000',
          projectId: '000',
        ),
      );
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }
}
