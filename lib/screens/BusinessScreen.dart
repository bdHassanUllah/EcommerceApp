import '../model/Model.dart';
import 'BusinessDetailScreen.dart';
import '../state_provider/StateProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessPage extends ConsumerWidget {
  const BusinessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsyncValue = ref.watch(businessProvider);

    return Scaffold(
      body: businessAsyncValue.when(
        data: (businessPosts) {
          if (businessPosts.isEmpty) {
            return const Center(child: Text("No business listings found"));
          }

          return ListView.builder(
            itemCount: businessPosts.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemBuilder: (context, index) {
              final business = businessPosts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusinessDetailScreen(
                        model: Model(
                          id: business['id']?.toString() ?? "None",
                          title: business["title"] ?? "No Title",
                          imageUrl: business["image"] ??
                              "https://via.placeholder.com/150",
                          content: business["full_description"] ??
                              "No content available.",
                          permalinks: business["permalink"] ??
                              "Sorry! Please try again",
                        ),
                        date: business["date"] != null
                            ? DateTime.tryParse(business["date"]) ??
                                DateTime.now()
                            : DateTime.now(), // Ensure proper date parsing
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
