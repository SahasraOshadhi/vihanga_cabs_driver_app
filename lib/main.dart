import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vihanga_cabs_driver_app/authentication/startup_screen.dart';

Future<void> main() async {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from the .env file
  try {
    await dotenv.load(fileName: ".env");
    print("API_KEY: ${dotenv.env['API_KEY']}");
  } catch (e) {
    print("Failed to load .env file: $e");
    // You can also handle the error more gracefully, e.g., by showing an error screen
  }

  // Initialize Firebase with the loaded environment variables
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['API_KEY'] ?? '',
        appId: dotenv.env['APP_ID'] ?? '',
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['STORAGE_BUCKET'] ?? '',
        databaseURL: dotenv.env['DATABASE_URL'] ?? '',
      ),
    );
  } catch (e) {
    print("Failed to initialize Firebase: $e");
    // You can also handle the error more gracefully, e.g., by showing an error screen
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StartUpScreen(),
    );
  }
}
