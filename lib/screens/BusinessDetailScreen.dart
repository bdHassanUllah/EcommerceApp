//import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:e_commerce/state_provider/BottomStateNavigator.dart';
import 'package:e_commerce/widgets/BottomNavigationWidget.dart';
import 'package:e_commerce/widgets/Functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final String imageUrl;
  final String content;
  final Map<String, dynamic> post;

  const BusinessDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.content,
    required this.post,
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
    //final selectedIndex = ref.watch(bottomNavProvider);
    final navigationNotifier = ref.read(bottomNavProvider.notifier);
    //final user = ref.watch(authStateProvider);

    return WillPopScope(
      onWillPop: () async {
        navigationNotifier.state = 0;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF2F4568),
          foregroundColor: Colors.white,
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                ShareUtil.sharePost(
                  context, 
                  widget.title, 
                  pageRoute: 'marketplace' // Custom route for marketplace posts
                );
              },
            ),

          ],

        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "lib/assets/image/placeholder.jpg",
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ShareUtil.removeHtmlTags(widget.title),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ShareUtil.removeHtmlTags(widget.content),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationWidget(),
      ),
    );
  }
}
