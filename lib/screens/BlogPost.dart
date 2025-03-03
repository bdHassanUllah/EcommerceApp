import 'package:e_commerce/screens/BlogDetailScreen.dart';
import 'package:e_commerce/state_provider/StateProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlogScreen extends ConsumerStatefulWidget {
  const BlogScreen({super.key});

  @override
  _BlogScreenState createState() => _BlogScreenState();
}

class _BlogScreenState extends ConsumerState<BlogScreen> {
  List<Map<String, String>> blogPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final blogAsyncValue = ref.watch(blogProvider); // ✅ Fetch data using Riverpod

    return Scaffold(
      body: blogAsyncValue.when(
        data: (blogsPosts) {
          if (blogsPosts.isEmpty) {
            return const Center(child: Text("No blog listings found"));
          }

          return ListView.builder(
            itemCount: blogsPosts.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final blogs = blogsPosts[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlogDetailScreen(
                        title: blogs["title"] ?? "No Title",
                        imageUrl: blogs["image"] ?? "https://via.placeholder.com/150",
                        content: blogs["content"]?.isNotEmpty == true ? blogs["content"]! : "Content not available",  
                        id: blogs['id'].toString(),
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
                        blogs["image"] ?? "lib/assets/image/placeholder.jpg",
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
                      blogs["title"] ?? "No Title",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
            
          );
          
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text("Error: $error")),
        
      ),
      
        );}
        }

