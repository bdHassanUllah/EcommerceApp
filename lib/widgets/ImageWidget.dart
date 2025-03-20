import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BusinessImageWidget extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;

  const BusinessImageWidget({
    super.key,
    required this.imageUrl,
    this.height = 80,
    this.width = 80,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Colors.grey[300], // Placeholder color
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Image.asset(
          "lib/assets/image/placeholder.jpg",
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
