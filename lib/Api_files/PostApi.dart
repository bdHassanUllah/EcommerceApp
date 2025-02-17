import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class ApiService {
  static final String baseUrl = "https://ecommerce.com.pk/wp-json/api/v1/happenings/"; // Replace with your actual API URL

  static Future<List<dynamic>> fetchPosts(String query) async {
    var box = Hive.box('cacheBox');
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'passkey': 'kW044]50^(ty',  // ✅ Passkey added here
          'Content-Type': 'application/json', // ✅ Ensure correct content type
        },
      );

      if (response.statusCode == 200) {
        // Log the response body to verify data
        print("Response Data: ${response.body}");
        
        var decodedData = jsonDecode(response.body);
        List<dynamic> data;

        if (decodedData is Map<String, dynamic>) {
          data = [decodedData];
        } else if (decodedData is List<dynamic>) {
          data = decodedData;
        } else {
          throw Exception("Unexpected API response format");
        }

        print("Decoded Data: $data"); // Log the decoded data

        // Store data in Hive for temporary use
        box.put('articles', data);
        return data;
      } else {
        throw Exception('Failed to load posts. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
