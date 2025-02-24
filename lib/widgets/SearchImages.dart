import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Searchimages extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap;

  const Searchimages({
    required this.imageUrl,
    required this.title,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 80,
        height: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Image.asset(
              'lib/assets/image/placeholder.png',
              fit: BoxFit.cover,
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}
