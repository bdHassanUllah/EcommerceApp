import 'package:e_commerce_app/Screens/MarketplaceDetailScreen.dart';
import 'package:e_commerce_app/state_provider/StateProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketplaceAsyncValue = ref.watch(marketplaceProviders); // Fetch data

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: marketplaceAsyncValue.when(
              data: (marketplaceItems) {
                print(
                  "Marketplace Data: $marketplaceItems",
                ); // Debug API response

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 30,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: marketplaceItems.length,
                    itemBuilder: (context, index) {
                      final item = marketplaceItems[index];

                      // Get the first available image from API response
                      final imageUrl = item["Image1"] ??
                          item["Image2"] ??
                          item["Image3"] ??
                          item["Image4"] ??
                          "https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png";

                      // Ensure title is not null
                      final title = item["title"] ?? "No Title";

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MarketplaceDetailScreen(
                                id: item["id"].toString(),
                                title: title,
                                imageUrl: imageUrl,
                                content:
                                    item["content"] ?? "No content available.",
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(
                                imageUrl,
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
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                0,
                                5.0,
                                0,
                                10.0,
                              ),
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text("Error: $error")),
            ),
          ),
        ],
      ),
    );
  }
}
