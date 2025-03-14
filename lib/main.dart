import 'package:e_commerce/model/HiveModel.dart';
import 'package:e_commerce/screens/HomeScreen.dart';
import 'package:e_commerce/screens/LoginScreen.dart';
import 'package:e_commerce/screens/ProfileScreen.dart';
import 'package:e_commerce/screens/SearchScreen.dart';
import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:e_commerce/screens/SplashScreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();

  // Delete existing box to avoid errors from old data
  if (await Hive.boxExists('postsBox')) {
    await Hive.deleteBoxFromDisk('postsBox');
  }

  // Register the Hive adapter
  Hive.registerAdapter(HiveModelAdapter());

  // Open Hive box for saved posts
  await Hive.openBox<HiveModel>('postsBox');

  runApp(const ProviderScope(child: MyApp()));
}

// Provider for accessing Hive storage
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
      home: const SplashScreen(), // Start from SplashScreen
      routes: {
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
