import 'package:e_commerce/state_provider/StateProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:e_commerce/screens/PostDetailScreen.dart';
import 'package:e_commerce/widgets/Functions.dart';
import 'package:e_commerce/widgets/SavedFunction.dart';

class PostWidget extends ConsumerWidget {
  const PostWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsyncValue = ref.watch(postProvider);
    final user = ref.watch(authStateProvider);
    final isLoggedIn = user != null;

    return postAsyncValue.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text("No posts found"));
        }

        return ListView.builder(
          itemCount: posts.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final post = posts[index];
            final isSaved = ref.watch(savedPostsProvider).contains(post.id);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(
                      post: post.toJson(),
                      postContent: post.content,
                      id: post.id,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  children: [
                    /// **Row for Title, Image, Save & Share**
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// **Post Title & Content**
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
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                        /// **Image**
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post.imageUrl,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset("assets/images/placeholder.jpg",
                                    height: 80, width: 80, fit: BoxFit.cover),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// **Row for Date-Time, Save & Share**
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// **Date & Time**
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.black, size: 16),
                            const SizedBox(width: 5),
                            Text(
                              DateFormat('MMMM dd, yyyy hh:mm a').format(
                                DateTime.tryParse(post.id) ?? DateTime.now(),
                              ),
                              style: const TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          ],
                        ),

                        /// **Save & Share Buttons**
                        Row(
                          children: [
                            /// **Save Button**
                            GestureDetector(
                              onTap: isLoggedIn
                                  ? () => ref.read(savedPostsProvider.notifier).toggleSave(post.id)
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
                                      fontWeight: isLoggedIn ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            /// **Share Button**
                            GestureDetector(
                              onTap: () {
                                ShareUtil.sharePost(context, post.id, pageRoute: 'postwidget');
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
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text("Error: $error")),
    );
  }
}
