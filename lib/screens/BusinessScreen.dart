import 'package:e_commerce/screens/BusinessDetailScreen.dart';
import 'package:e_commerce/Api_files/BusinessApi.dart';
import 'package:flutter/material.dart';

class BusinessPage extends StatefulWidget {
  const BusinessPage({super.key});

  @override
  State<BusinessPage> createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  late Future<List<Map<String, dynamic>>> businessUrl;

  @override
  void initState() {
    super.initState();
    businessUrl = BusinessApi.fetchBusinessPosts();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: BusinessApi.fetchBusinessPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No business listings found"));
          }
          List<Map<String, dynamic>> businessPosts = snapshot.data!;

          return ListView.builder(
            itemCount: businessPosts.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final business = businessPosts[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusinessDetailScreen(
                        title: business["title"] ?? "No Title",
                        imageUrl: business["image"] ?? "https://via.placeholder.com/150",
                        content: business["full_description"] ?? "No content available.", // ✅ Avoids null error
                        post: business,
                      ),
                    ),
                  );

                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        business["image"] ?? "lib/assets/image/placeholder.jpg",
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "lib/assets/image/placeholder.jpg",
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      business["title"] ?? "No Title",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
