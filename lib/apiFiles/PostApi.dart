import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

// API Service
class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<dynamic>> fetchData(String endpoint) async {
    var box = Hive.box('cacheBox');

    try {
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          'passkey': 'kW044]50^(ty',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Ensure the response body is not null
        if (response.body.isEmpty) {
          return []; // Return an empty list if the response is empty
        }

        var decodedData = jsonDecode(response.body);

        // Ensure the decoded data is always a List<dynamic>
        List<dynamic> data = decodedData is Map<String, dynamic> ? [decodedData] : decodedData ?? [];

        // Cache the data in Hive
        for (var post in data) {
          if (post is Map<String, dynamic> && post.containsKey('id')) {
            box.put(post['id'].toString(), post);
          }
        }

        return data;
      } else {
        throw Exception('Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Error fetching data from $endpoint: $e");
    }
  }

  Future<List<dynamic>> fetchPosts() => fetchData("/happenings");
}
