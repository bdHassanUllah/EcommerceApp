import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class ImgApiURL{
  static String apiUrl = "https://ecommerce.com.pk/wp-content/uploads/2025/02/Ecommerce-Banner-86.png";

  // Method to fetch Image
  Future<List<dynamic>> fetchImage() async {
    var imgBox = Hive.box('cacheBox');
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> imagesData = response.bodyBytes;
        
        if (imagesData.isNotEmpty) {
          imgBox.put('images', imagesData); // Cache the images
          return imagesData;
        }
      }
      throw Exception('No images found');
    } catch (e) {
      throw Exception('Error fetching images: $e');
    }
  }
}