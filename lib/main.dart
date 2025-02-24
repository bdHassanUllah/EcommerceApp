import 'package:e_commerce/screens/HomeScreen.dart';
import 'package:e_commerce/screens/LoginScreen.dart';
import 'package:e_commerce/screens/ProfileScreen.dart';
import 'package:e_commerce/screens/SearchScreen.dart';
import 'package:e_commerce/state_provider/AuthStateProvider.dart';
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

  runApp(const ProviderScope(child: MyApp())); // Wrap in ProviderScope
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/SplashScreen',
      routes: {
        '/SplashScreen': (context) => SplashScreen(), 
        '/home': (context) => HomeScreen(),
        '/search': (context) => SearchScreen(),
        '/loginscreen': (context) => LoginScreen(),
        '/profile': (context) => ProfileScreen(
          userName: user?.displayName ?? 'Guest',
          userImage: user?.photoURL ?? 'https://via.placeholder.com/150',
        ),
      },
    );
  }
}
