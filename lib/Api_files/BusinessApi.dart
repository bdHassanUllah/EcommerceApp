import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class BusinessApi {
  static Future<List<Map<String, dynamic>>> fetchBusinessPosts() async {
    final url = Uri.parse("https://ecommerce.com.pk/wp-json/api/v1/businesses/");

    try {
      final response = await http.get(
        url,
        headers: {
          'passkey': 'kW044]50^(ty',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("API Response: ${response.body}"); // ✅ Print API response

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.isEmpty) {
          debugPrint("API returned an empty list!"); // ✅ Log empty response
          return [];
        }

        return jsonResponse.map((post) {
          return {
            "id": post["id"]?.toString() ?? "0",
            "title": _parseHtmlToText(post["title"] ?? "No Title"),
            "image": post["Image1"] ?? "https://example.com/default.jpg",
            "description": _parseHtmlToText(post["description"] ?? "No Description"),
            "full_description": _parseHtmlToText(post["content"] ?? "No Full Description"),
          };
        }).toList();
      } else {
        debugPrint("Error: Status Code ${response.statusCode}");
        return [];
      }
    } catch (error) {
      debugPrint("Error fetching business data: $error");
      return [];
    }
  }

  // Function to remove HTML tags
  static String _parseHtmlToText(String htmlString) {
    return parse(htmlString).body?.text ?? '';
  }
}
