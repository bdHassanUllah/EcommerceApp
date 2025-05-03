import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketplaceUrl {
  final String baseUrl;

  MarketplaceUrl({required this.baseUrl});

  Future<List<dynamic>> getData(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          'passkey': 'kW044]50^(ty',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load marketplace posts");
      }
    } catch (error) {
      print("Error fetching marketplace data: $error");
      throw Exception("Network error: $error");
    }
  }
  Future<List<dynamic>> fetchMarketplacePosts() => getData("/marketplaces");
}
