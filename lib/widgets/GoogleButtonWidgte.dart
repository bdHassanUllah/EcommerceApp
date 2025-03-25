import 'package:flutter/material.dart';

class RoundedButtonWithImage extends StatelessWidget {
  final ImageProvider image;
  final String text;
  final VoidCallback onPressed;

  const RoundedButtonWithImage({super.key, 
    required this.image,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Rounded corners
        ),
        side: BorderSide(color: Colors.grey), // Border color
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image(image: image, width: 24, height: 24), // Image
          SizedBox(width: 10), // Space between image and text
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87, // Text color
            ),
          ),
        ],
      ),
    );
  }
}