import 'dart:convert';
import '../model/HiveModel.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class PostRepository {
  final String baseUrl;
  final Box<HiveModel> postBox;

  PostRepository({
    required this.baseUrl,
    required this.postBox,
  });

  // Fetch Posts from API or Cache
  Future<List<HiveModel>> fetchData(String endpoint) async {
  try {
    print("🔄 Fetching posts from API...");
    final response = await http.get(
      Uri.parse("$baseUrl/happenings"),
      headers: {
        'passkey': 'kW044]50^(ty',
        'Content-Type': 'application/json',
      },
    );

    print("🌐 API Response Code: ${response.statusCode}");
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      print("📊 Raw API Response Data: $jsonData");

      List<HiveModel> posts = jsonData.map((data) {
        final hivePost = HiveModel(
          id: data['id'].toString(),
          title: data['title'] ?? 'No Title',
          imageUrl: data['featured_image'] ?? data['thumbnail'] ?? '',
          content: data['content'] ?? '',
          date: data['created_date'] != null
              ? DateTime.tryParse(data['created_date'].toString()) ?? DateTime.now()
              : DateTime.now(),
          permalink: data['permalink'] ?? "https://ecommerce.com.pk",
        );
        print("✅ Converted Post: ${hivePost.title}");
        return hivePost;
      }).toList();

      // Save to Hive Cache
      for (var post in posts) {
        postBox.put(post.id, post);
      }
      print("✅ Posts saved to Hive: ${postBox.values.toList().map((e) => e.title)}");

      return posts;
    } else {
      print("❌ Failed to load posts. Status Code: ${response.statusCode}");
      throw Exception('Failed to load data.');
    }
  } catch (e) {
    print("⚠️ Error fetching posts: $e");
    return postBox.values.toList(); // Fallback to cached data
  }
}

  Future<List<dynamic>> fetchPosts() => fetchData("/happenings");
}