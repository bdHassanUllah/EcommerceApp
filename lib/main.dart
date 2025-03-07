import 'package:e_commerce/model/HiveModel.dart';
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

  // Register the generated adapter (not the model)
  Hive.registerAdapter(HiveModelAdapter()); // No constructor parameters needed

  // Open box with model type
  await Hive.openBox<HiveModel>('postsBox'); // Use HiveModel, not the adapter
  //await box.clear(); 
  
  runApp(const ProviderScope(child: MyApp()));
}

// Update provider to use HiveModel
final hiveBoxProvider = Provider<Box<HiveModel>>((ref) {
  return Hive.box<HiveModel>('postsBox');
});

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
