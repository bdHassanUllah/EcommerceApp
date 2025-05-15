import '../model/HiveModel.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Required for Riverpod
import 'SavedFunction.dart';
import 'package:http/http.dart' as http; // Import http package for API calls
import 'dart:convert'; // Import for JSON decoding

class ShareUtil {
  static Future<void> sharePost(
    BuildContext context,
    String postId, {
    required String pageRoute,
  }) async {
    // Fetch the post from Hive or API
    var box = Hive.box<HiveModel>('postsBox');
    HiveModel? post = box.get(postId);

    // Use the permalink from the post
    final String postUrl = post!.permalink;
    Share.share(postUrl, subject: 'Check out this post!');
    }

  static String removeHtmlTags(String htmlString) {
    String withoutShortcodes = htmlString.replaceAll(RegExp(r'\[.*?\]'), '');
    dom.Document document = html_parser.parse(withoutShortcodes);
    String plainText = document.body?.text ?? '';
    return plainText.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static Widget buildPopupMenu({
    required BuildContext context,
    required WidgetRef ref,
    required String postId,
    required post,
    required VoidCallback toggleSavePost,
  }) {
    final isSaved = ref.watch(savedPostsProvider).contains(postId);

    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == "save") {
          toggleSavePost();
        } else if (value == "share") {
          await sharePost(context, postId, pageRoute: 'postdetailscreen');
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: "save",
          child: Row(
            children: [
              Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? Colors.black : Colors.grey,
              ),
              const SizedBox(width: 10),
              Text(isSaved ? "Unsave" : "Save"),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: "share",
          child: Row(
            children: [
              Icon(Icons.share, color: Colors.black),
              SizedBox(width: 10),
              Text("Share"),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> sharePost(
  BuildContext context,
  String postId, {
  required String pageRoute,
}) async {
  // Fetch the correct URL from your API
  final String apiUrl =
      "https://ecommerce.com.pk/wp-json/api/v1/$pageRoute/$postId";
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final String postUrl =
        data['url']; // Assuming the API returns a 'url' field

    Share.share(postUrl, subject: 'Check out this post!');
  } else {
    // Handle error
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Failed to load post URL')));
  }
}

String removeHtmlTags(String htmlString) {
  String withoutShortcodes = htmlString.replaceAll(RegExp(r'\[.*?\]'), '');
  dom.Document document = html_parser.parse(withoutShortcodes);
  String plainText = document.body?.text ?? '';
  return plainText.replaceAll(RegExp(r'\s+'), ' ').trim();
}

Widget buildPopupMenu({
  required BuildContext context,
  required WidgetRef ref,
  required String postId,
  required post,
  required VoidCallback toggleSavePost,
}) {
  final isSaved =
      ref.watch(savedPostsProvider).contains(postId); // ✅ Watch state

  return PopupMenuButton<String>(
    onSelected: (value) async {
      if (value == "save") {
        toggleSavePost(); // ✅ Pass context for Snackbar
      } else if (value == "share") {
        await sharePost(context, postId, pageRoute: 'postdetailscreen');
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem<String>(
        value: "save",
        child: Row(
          children: [
            Icon(
              isSaved
                  ? Icons.bookmark
                  : Icons.bookmark_border, // ✅ Dynamic icon update
              color: isSaved ? Colors.black : Colors.grey,
            ),
            const SizedBox(width: 10),
            Text(isSaved ? "Unsave" : "Save"),
          ],
        ),
      ),
      const PopupMenuItem<String>(
        value: "share",
        child: Row(
          children: [
            Icon(Icons.share, color: Colors.black),
            SizedBox(width: 10),
            Text("Share"),
          ],
        ),
      ),
    ],
  );
}
