import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SavedArticlesScreen extends StatelessWidget {
  final String userEmail;

  const SavedArticlesScreen({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Saved Articles")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('saved_articles')
            .where('email', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var articles = snapshot.data!.docs;

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              var article = articles[index];
              return ListTile(
                leading: Image.network(article['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                title: Text(article['title']),
                subtitle: Text(article['content']),
              );
            },
          );
        },
      ),
    );
  }
}
