import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketplaceUrl {
  static Future<List<Map<String, dynamic>>> fetchMktPosts() async { 
    final response = await http.get(
      Uri.parse("https://ecommerce.com.pk/wp-json/api/v1/marketplaces"),
      headers: {
        'passkey': 'kW044]50^(ty',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      
      return jsonData.cast<Map<String, dynamic>>(); // ✅ Return as List<Map<String, dynamic>>
    } else {
      throw Exception("Failed to load marketplace posts");
    }
  }
}
