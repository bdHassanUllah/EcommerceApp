import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:e_commerce/screens/SplashScreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();

  var box = await Hive.openBox('cacheBox'); // Open a storage box
  await box.clear(); // Clear storage when app starts

  runApp(const ProviderScope(child: MyApp())); // Initialize Riverpod
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
