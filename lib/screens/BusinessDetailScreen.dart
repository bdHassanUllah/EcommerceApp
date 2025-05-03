import '../model/Model.dart';
import '../state_provider/BottomStateNavigator.dart';
import '../widgets/BottomNavigationWidget.dart';
import '../widgets/Functions.dart';
import '../widgets/ScrollFunctions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessDetailScreen extends ConsumerStatefulWidget {
  final Model model; // Now using Model object
  final DateTime date;

  const BusinessDetailScreen({
    super.key,
    required this.model,
    required this.date,
  });

  @override
  _BusinessDetailScreenState createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends ConsumerState<BusinessDetailScreen> {
  bool isLoggedIn = false;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      isLoggedIn = user != null;
      userEmail = user?.email?.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationNotifier = ref.read(bottomNavProvider.notifier);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          navigationNotifier;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2F4568),
          foregroundColor: Colors.white,
          title: Text(widget.model.title), // Access title from Model
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                ShareUtil.sharePost(
                  context,
                  widget.model.title, // Use Model title
                  pageRoute: 'marketplace',
                );
              },
            ),
          ],
        ),
        body: ScrollableContentWidget(
          imageUrl: widget.model.imageUrl, // Use Model imageUrl
          title: widget.model.title, // Use Model title
          content: widget.model.content, // Use Model content
          date: widget.date,
        ),
        bottomNavigationBar: BottomNavigationWidget(),
      ),
    );
  }
}
