import '../model/HiveModel.dart';
import '../screens/PostDetailScreen.dart';
import '../state_provider/SavedPost.dart';
import '../state_provider/AuthStateProvider.dart';
import 'Functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PostWidget extends ConsumerWidget {
  final dynamic post;
  const PostWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final isLoggedIn = user != null;
    final savedPosts = ref.watch(savedPostsProvider);
    final isSaved = savedPosts.contains(post.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              hiveModels: HiveModel(
                id: post.id.toString(),
                title: post.title ?? "None",
                imageUrl: post.imageUrl ?? "featured_image",
                content: post.content ?? "No content available",
                date: post.date ?? "created_date",
                permalink: post.permalink ?? "https://ecommerce.com.pk",
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        ShareUtil.removeHtmlTags(post.content),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrl,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      "lib/assets/image/placeholder.jpg",
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.black,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      post.date is DateTime
                          ? DateFormat('dd MMM yyyy, hh:mm a').format(post.date)
                          : (DateTime.tryParse(post.date.toString()) != null
                              ? DateFormat(
                                  'dd MMM yyyy, hh:mm a',
                                ).format(DateTime.parse(post.date.toString()))
                              : "Unknown Date"),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: isLoggedIn
                          ? () => ref
                              .read(savedPostsProvider.notifier)
                              .toggleSave(post.id, context)
                          : null,
                      child: Row(
                        children: [
                          Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: isSaved ? Colors.black : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Save",
                            style: TextStyle(
                              color: isLoggedIn ? Colors.black : Colors.grey,
                              fontSize: 12,
                              fontWeight: isLoggedIn
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ShareUtil.sharePost(
                          context,
                          post.id,
                          pageRoute: 'postwidget',
                        );
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            'lib/assets/image/share_logo.png',
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "Share",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
