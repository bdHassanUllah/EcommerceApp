import 'dart:convert';
import 'package:e_commerce/model/HiveModel.dart';
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
      final response = await http.get(
        Uri.parse("$baseUrl/happenings"),
        headers: {
          'passkey': 'kW044]50^(ty',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        
        // Convert JSON to List<HiveModel>
        List<HiveModel> posts = jsonData.map((data) => HiveModel(
          id: data['id'].toString(),
          title: data['title'] ?? 'No Title',
          imageUrl: data['featured_image'] ?? data['thumbnail'] ?? '',
          content: data['content'] ?? '',
          date: data['created_date'] != null
              ? DateTime.tryParse(data['created_date'].toString()) ?? DateTime.now()
              : DateTime.now(), 
          permalink: data.permalink ?? "https://ecommerce.com.pk", // Fixed `data['date']`
        )).toList();

        // Save to Hive Cache
        for (var post in posts) {
          postBox.put(post.id, post);
        }

        return posts;
      } else {
        throw Exception('Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // If API fails, return cached data
      return postBox.values.toList();
    }
  }
  Future<List<dynamic>> fetchPosts() => fetchData("/happenings");
}