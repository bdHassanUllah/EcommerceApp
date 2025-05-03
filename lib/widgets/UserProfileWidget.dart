import 'package:flutter/material.dart';

class UserProfileWidget extends StatelessWidget {
  final String userName;
  final String userImage;

  const UserProfileWidget({
    super.key,
    required this.userName,
    required this.userImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: userImage.isNotEmpty
              ? NetworkImage(userImage)
              : const AssetImage('lib/assets/image/default_avatar.png') as ImageProvider,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
