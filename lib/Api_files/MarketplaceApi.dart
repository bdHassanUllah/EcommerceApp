import 'package:http/http.dart' as http;
import 'dart:convert';

class MarketplaceUrl {
  static Future<List<dynamic>> fetchMktPosts(String query) async {
    final url = Uri.parse("https://ecommerce.com.pk/wp-json/api/v1/marketplaces/");

    try {
      final response = await http.get(
        url,
        headers: {
          'passkey': 'kW044]50^(ty',  // ✅ Add passkey here
          'Content-Type': 'application/json',  // ✅ Ensure correct content type
        },
      );

      print("API Status Code: ${response.statusCode}"); // Debugging
      print("API Response: ${response.body}"); // Debugging

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load marketplace data. Status Code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching marketplace data: $error"); // Debugging
      throw Exception("Network error: $error");
    }
  }
}
