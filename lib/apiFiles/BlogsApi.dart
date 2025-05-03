import 'dart:convert';
import '../model/HiveModel.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class Blogsapi {
  final String blogBaseUrl;

  Blogsapi({required this.blogBaseUrl});

  Future<List<HiveModel>> getBlogsData(String endpoint) async {
    var box = Hive.box<HiveModel>(
      'postsBox',
    ); // Ensure consistency in Hive box naming

    try {
      final response = await http.get(
        Uri.parse("$blogBaseUrl$endpoint"),
        headers: {
          'passkey': 'kW044]50^(ty',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        List<HiveModel> blogsData = [];

        for (var item in jsonData) {
          if (item is Map<String, dynamic> && item.containsKey('id')) {
            String postId = item["id"].toString();
            // In Blogsapi class
            HiveModel post = HiveModel(
              id: postId,
              title: (item["title"] ?? "No Title").split(":").first.trim(),
              imageUrl:
                  item["featured_image"] ?? "https://via.placeholder.com/150",
              content: item["content"] ?? "No content available",
              date:
                  item['created_date'] != null
                      ? DateTime.tryParse(item['created_date']) ??
                          DateTime.now()
                      : DateTime.now(),
              permalink: item['permalink']?.toString() ?? "None",
            );

            blogsData.add(post);

            // Save only if not already stored
            if (!box.containsKey(postId)) {
              box.put(postId, post);
            }
          }
        }

        print("✅ Blog posts saved in Hive!");
        return blogsData;
      } else {
        throw Exception("Failed to load blog posts: ${response.statusCode}");
      }
    } catch (error) {
      print("❌ Error fetching blog data: $error");

      // Return cached Hive data if API fails
      List<HiveModel> cachedData = box.values.toList();
      if (cachedData.isNotEmpty) {
        print("📦 Returning cached data from Hive.");
        return cachedData;
      } else {
        throw Exception("No data found in Hive and API request failed.");
      }
    }
  }

  Future<List<HiveModel>> fetchBlogPosts() => getBlogsData("/blogs");
}
