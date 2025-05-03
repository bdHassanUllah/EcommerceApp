import 'package:flutter/material.dart';

class RoundedButtonWithImage extends StatelessWidget {
  final AssetImage image;
  final String text;
  final VoidCallback onPressed;

  const RoundedButtonWithImage({
    super.key,
    required this.image,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ), backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 5), // Background color
        side: BorderSide(color: Colors.grey.shade300),
        minimumSize: Size(double.infinity, 50), // Set a fixed height for the button
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centers the content horizontally
        crossAxisAlignment: CrossAxisAlignment.center, // Centers the content vertically
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 0), // Remove extra space from left of the icon
            child: Image(image: image, width: 10, height: 24), // Image
          ),
          const SizedBox(width: 5), // Space between image and text
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
