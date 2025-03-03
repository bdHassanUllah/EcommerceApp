import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:share_plus/share_plus.dart';

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
}
