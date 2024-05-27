import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vihanga_cabs_driver_app/authentication/startup_screen.dart';

Future <void> main  () async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'key',
        appId: 'id',
        messagingSenderId: 'sendid',
        projectId: 'myapp',
        storageBucket: 'vihanga-cabs-flutter-app.appspot.com',
      )
  );

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

