import 'package:http/http.dart' as http;
import 'dart:convert';

class Businessurl {
  static final businessUrl = Uri.parse("https://ecommerce.com.pk/wp-json/api/v1/businesses/"); 

  static Future<List<Map<String, String>>> fetchBusinessPosts(String query) async {
    try {
      final response = await http.get(businessUrl,headers: {
          'passkey': 'kW044]50^(ty',  // ✅ Add passkey here
          'Content-Type': 'application/json',  // ✅ Ensure correct content type
        },);

      print("API Status Code: ${response.statusCode}");
      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        // Extract title and image URL
        List<Map<String, String>> businessData = jsonData.map((item) {
          String fullTitle = item["title"] ?? "No Title";
          String imageUrl = item["featured_image"] ?? "https://via.placeholder.com/150"; // Default image

          // Extract first words before ":" (if exists)
          String extractedTitle = fullTitle.contains(":") ? fullTitle.split(":")[0].trim() : fullTitle;

          return {
            "title": extractedTitle,
            "image": imageUrl,
          };
        }).toList();

        return businessData;
      } else {
        throw Exception("Failed to load business data");
      }
    } catch (error) {
      print("Error fetching business data: $error");
      throw Exception("Network error: $error");
    }
  }
}
