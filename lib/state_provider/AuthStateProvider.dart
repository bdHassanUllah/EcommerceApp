/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});
final userProvider = StateProvider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});
class AuthNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthNotifier() : super(null) {
    _checkUserStatus();
  }

  // Check if user is logged in
  void _checkUserStatus() {
    state = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      state = user; // Update state when user logs in or out
    });
  }

  // Logout function
  Future<void> signOut() async {
    await _auth.signOut();
    state = null;
  }
}*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, User?>((ref) {
  return AuthStateNotifier();
});

final userProvider = StateProvider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});


class AuthStateNotifier extends StateNotifier<User?> {
  AuthStateNotifier() : super(FirebaseAuth.instance.currentUser) {
    // Listen to authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      state = user;
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    state = null; // This triggers UI updates
  }
}
