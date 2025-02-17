import 'package:e_commerce/Api_files/BusinessApi.dart';
import 'package:flutter/material.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  late Future<List<dynamic>> businessPosts;

  @override
  void initState() {
    super.initState();
    businessPosts = Businessurl.fetchBusinessPosts('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: businessPosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No business-related posts found"));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var post = snapshot.data![index];
                    String title = post["title"] ?? "No Title";
                    String imageUrl = post["featured_image"] ?? "";
                    return _businessCard(title, imageUrl);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTab(String title, {bool isActive = false}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        decoration: isActive ? TextDecoration.underline : TextDecoration.none,
      ),
    );
  }

  Widget _businessCard(String title, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset("lib/assets/image/placeholder.png", height: 180, fit: BoxFit.cover);
              },
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
