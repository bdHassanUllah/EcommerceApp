import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting
import '../widgets/Functions.dart'; // Import your utility function

class ScrollableContentWidget extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String content;
  final DateTime date;

  const ScrollableContentWidget({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.content,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    // Format the date in a readable format
    String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl.isNotEmpty ? imageUrl : 'default_image_url',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 0.5,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              "lib/assets/image/placeholder.jpg",
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ShareUtil.removeHtmlTags(title),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Published on: $formattedDate", // Display formatted date
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),

                Text(
                  content.isNotEmpty
                      ? ShareUtil.removeHtmlTags(content)
                      : 'Content not available',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
