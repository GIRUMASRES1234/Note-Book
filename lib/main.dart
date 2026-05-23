import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';


import 'features/splash/ui/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await Hive.initFlutter();

  Hive.openBox('notesBox');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Notebook',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff0f172a), // ✅ FIX FLASH
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const SplashScreen(),
    );
  }
}
