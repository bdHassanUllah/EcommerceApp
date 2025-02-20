import 'package:http/http.dart' as http;
import 'dart:convert';

class Blogsapi {
  static final BlogUrl = Uri.parse("https://ecommerce.com.pk/wp-json/api/v1/blogs"); 

  static Future<List<Map<String, String>>> fetchBlogsPosts(String query) async {
  try {
    final response = await http.get(
      BlogUrl,
      headers: {
        'passkey': 'kW044]50^(ty',  
        'Content-Type': 'application/json',  
      },
    );

    print("API Status Code: ${response.statusCode}");
    print("API Response: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);

      // Extract title, image URL, and content
      List<Map<String, String>> businessData = jsonData.map((item) {
        String fullTitle = item["title"] ?? "No Title";
        String imageUrl = item["featured_image"] ?? "https://via.placeholder.com/150"; 
        String extractedTitle = fullTitle.contains(":") ? fullTitle.split(":")[0].trim() : fullTitle;
        String content = item["content"] ?? "No content available"; // ✅ Extract content

        return {
          "title": extractedTitle,
          "image": imageUrl,
          "content": content, // ✅ Add content field
        };
      }).toList();

      return businessData;
    } else {
      throw Exception("Failed to load blog posts");
    }
  } catch (error) {
    print("Error fetching blog data: $error");
    throw Exception("Network error: $error");
  }
}

}
