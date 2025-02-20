import 'package:e_commerce/screens/BlogDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  _BlogScreenState createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  List<Map<String, String>> blogPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBlogPosts();
  }

  Future<void> fetchBlogPosts() async {
    try {
      final response = await http.get(
        Uri.parse("https://ecommerce.com.pk/wp-json/api/v1/blogs/"),
        headers: {
          'passkey': 'kW044]50^(ty',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        List<Map<String, String>> businessData = jsonData.map((item) {
          String fullTitle = item["title"] ?? "No Title";
          String imageUrl = item["featured_image"] ?? "https://via.placeholder.com/150";
          String extractedTitle = fullTitle.contains(":") ? fullTitle.split(":")[0].trim() : fullTitle;
          String content = item["content"] ?? "No content available"; 
          
          return {
            "title": extractedTitle,
            "image": imageUrl,
            "content": content, //Pass content
          };
        }).toList();

        setState(() {
          blogPosts = businessData;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load blog posts");
      }
    } catch (error) {
      print("Error fetching blog data: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: blogPosts.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlogDetailScreen(
                                    title: blogPosts[index]["title"] ?? "No Title",
                                    imageUrl: blogPosts[index]["image"] ?? "https://via.placeholder.com/150",
                                    content: blogPosts[index]["content"] ?? "No content available.", // ✅ Avoids null error
                                  ),
                                ),
                              );
                            },

                            child: _buildBlogPost(
                              title: blogPosts[index]["title"]!,
                              imageUrl: blogPosts[index]["image"]!,
                            ),
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogPost({required String title, required String imageUrl}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Image.network(
          imageUrl,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset("lib/assets/image/placeholder.jpg", width: 120, height: 120, fit: BoxFit.cover);
          },
        ),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        trailing: Image.asset(
          'lib/assets/image/share_logo.png',
          height: 30,
          width: 30,
        ),
      ),
    );
  }
}
