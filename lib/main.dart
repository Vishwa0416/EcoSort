import 'package:ecosort/screens/landing/landingpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("Environment variables loaded successfully!");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First page of EcoSort',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const Landingpage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

