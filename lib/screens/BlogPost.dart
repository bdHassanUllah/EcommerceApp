import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'BlogDetailScreen.dart';
import '../state_provider/StateProvider.dart';
import 'package:hive/hive.dart';
import '../model/HiveModel.dart';

class BlogScreen extends ConsumerStatefulWidget {
  const BlogScreen({super.key});

  @override
  _BlogScreenState createState() => _BlogScreenState();
}

class _BlogScreenState extends ConsumerState<BlogScreen> {
  @override
  Widget build(BuildContext context) {
    final blogAsyncValue = ref.watch(blogProvider); //Fetch data using Riverpod

    return Scaffold(
      body: blogAsyncValue.when(
        data: (blogsPosts) {
          if (blogsPosts.isEmpty) {
            return const Center(child: Text("No blog listings found"));
          }

          // Debug: Print Hive data for verification
          var box = Hive.box<HiveModel>('postsBox');
          print("Hive Stored Keys: ${box.keys.toList()}");
          print("Hive Stored Posts: ${box.values.toList()}");

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
                        hiveModel: HiveModel(
                          id: blogs.id.toString(),
                          title: blogs.title,
                          imageUrl: blogs.imageUrl,
                          content: blogs.content,
                          date: blogs.date ?? DateTime.now(),
                          permalink:
                              blogs.permalink ?? "https://ecommerce.com.pk",
                        ),
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
                        blogs.imageUrl,
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
                      blogs.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
    );
  }
}
