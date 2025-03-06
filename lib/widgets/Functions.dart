import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Required for Riverpod
import 'package:e_commerce/widgets/SavedFunction.dart';

class ShareUtil {
  static void sharePost(BuildContext context, String postId, {required String pageRoute}) {
    final String postUrl = "https://ecommerce.com.pk/wp-json/api/v1/$pageRoute/$postId";
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
  final isSaved = ref.watch(savedPostsProvider).contains(postId); // ✅ Watch state

  return PopupMenuButton<String>(
    onSelected: (value) {
      if (value == "save") {
        toggleSavePost();  // ✅ Pass context for Snackbar
      } else if (value == "share") {
        sharePost(context, postId, pageRoute: 'postdetailscreen');
      }
    },

    itemBuilder: (context) => [
      PopupMenuItem<String>(
        value: "save",
        child: Row(
          children: [
            Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border, // ✅ Dynamic icon update
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


