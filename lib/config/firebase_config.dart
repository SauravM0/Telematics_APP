import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          // Replace with your Firebase configuration values from google-services.json
          apiKey: 'AIzaSyB8d9FirFkz3fyBn7m4WOCWP7vh834nXrQ',
          appId: '1:658357887443:android:abcdef1234567890',
          messagingSenderId: '658357887443',
          projectId: 'telematics-641f1',
        ),
      );
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }
}