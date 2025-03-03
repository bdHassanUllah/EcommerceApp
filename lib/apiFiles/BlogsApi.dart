import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_commerce/model/HiveModel.dart';
import 'package:hive/hive.dart';

class Blogsapi {
  final String blogBaseUrl;

  Blogsapi({required this.blogBaseUrl});

  Future<List<HiveModel>> getBlogsData(String endpoint) async {
    var box = Hive.box<HiveModel>('postsBox'); // Use the correct box

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
        List<HiveModel> postsToSave = [];

        List<HiveModel> businessData = jsonData.map((item) {
          String postId = item["id"].toString();
          HiveModel post = HiveModel(
            id: postId,
            title: (item["title"] ?? "No Title").split(":").first.trim(),
            imageUrl: item["featured_image"] ?? "https://via.placeholder.com/150",
            content: item["content"] ?? "No content available",
          );

          if (!box.containsKey(postId)) {
            postsToSave.add(post);
          }
          return post;
        }).toList();

        if (postsToSave.isNotEmpty) {
          box.addAll(postsToSave); // Save new posts
          print("💾 Saved ${postsToSave.length} new posts in Hive.");
        }

        return businessData;
      } else {
        throw Exception("Failed to load blog posts: ${response.statusCode}");
      }
    } catch (error) {
      print("❌ Error fetching blog data: $error");
      return [];
    }
  }

  Future<List<HiveModel>> fetchBlogPosts() => getBlogsData("/blogs");
}