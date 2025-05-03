import '../model/MarketplaceModel.dart';
import 'package:flutter/material.dart';

class MarketplaceItem extends StatelessWidget {
  final MarketplaceItemData item;

  const MarketplaceItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        // Make the card tappable
        onTap: () {
          // Handle item tap - navigate to details, etc.
          print('Tapped on ${item.title}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.asset(
                // Or Image.network if using URLs
                item.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, object, stackTrace) =>
                    const Icon(Icons.error), // Handle image errors
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1, // Limit title to one line
                    overflow:
                        TextOverflow.ellipsis, // Add ellipsis if it overflows
                  ),
                  if (item.subtitle != null) // Conditionally show subtitle
                    Text(
                      item.subtitle!,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
