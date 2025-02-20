import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'MarketplaceDetailScreen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<Map<String, String>> marketplaceItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMktPosts();
  }

  Future<void> fetchMktPosts() async {
  try {
    final response = await http.get(
      Uri.parse("https://ecommerce.com.pk/wp-json/api/v1/marketplaces"),
      headers: {
        'passkey': 'kW044]50^(ty',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);

      List<Map<String, String>> marketplaceData = jsonData.map<Map<String, String>>((item) {
        String fullTitle = item["title"] ?? "No Title";

        // Default placeholder image
        String placeholderImage = "https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png";

        // Get the first available image from API response
        String imageUrl = item["Image1"] ?? item["Image2"] ?? item["Image3"] ?? item["Image4"] ?? placeholderImage;

        // Ensure the image URL is valid
        if (imageUrl.isEmpty || !Uri.tryParse(imageUrl)!.hasAbsolutePath) {
          imageUrl = placeholderImage;
        }

        // Extract title before ':'
        String extractedTitle = fullTitle.contains(":") ? fullTitle.split(":")[0].trim() : fullTitle;
        return {
          "title": extractedTitle,
          "image": imageUrl,
          "content": item["content"] ?? "No content available",
        };
      }).toList();

      setState(() {
        marketplaceItems = marketplaceData;
        isLoading = false;
      });
    } else {
      throw Exception("Failed to load marketplace posts");
    }
  } catch (error) {
    print("Error fetching marketplace data: $error");
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
          const Padding(
            padding: EdgeInsets.all(16.0),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two columns
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 0,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: marketplaceItems.length,
                      itemBuilder: (context, index) {
                        final image = marketplaceItems[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MarketplaceDetailScreen(
                                  title: marketplaceItems[index]["title"] ?? "No Title",
                                  imageUrl: marketplaceItems[index]["image"] ?? "https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png",
                                  content: marketplaceItems[index]["content"] ?? "No content available.",
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  image["image"] ?? "lib/assets/image/placeholder.jpg",
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
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  marketplaceItems[index]["title"]!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildDivider(index),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(int index) {
    return Column(
      children: [
        if ((index + 1) % 2 == 0) // Horizontal divider after every row
          const Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        if (index.isEven) // Vertical divider in between columns
          const VerticalDivider(
            thickness: 1,
            color: Colors.grey,
          ),
      ],
    );
  }
}
