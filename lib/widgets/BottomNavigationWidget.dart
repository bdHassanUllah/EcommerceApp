import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../state_provider/AuthStateProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state_provider/BottomStateNavigator.dart';

// class BottomNavigationWidget extends ConsumerWidget {
//   const BottomNavigationWidget({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedIndex = ref.watch(bottomNavProvider);
//     final user = ref.watch(authStateProvider); // Listen to auth state changes

//     return CurvedNavigationBar(
//       backgroundColor: Colors.white, // Background behind the bar
//       color: const Color(0xFF2F4568), // Nav bar color
//       buttonBackgroundColor: Colors.white, // Active icon background
//       animationDuration: const Duration(minutes: 5), // Smooth animation
//       index: selectedIndex, // Set selected tab
//       onTap: (index) {
//         ref.read(bottomNavProvider.notifier).setIndex(index, context);
//       },
//       items: [
//         Icon(
//           Icons.home,
//           size: 30,
//           color: selectedIndex == 0
//               ? Colors.black
//               : Colors.white, // Active: Black, Inactive: White
//         ),
//         Icon(
//           Icons.search,
//           size: 30,
//           color: selectedIndex == 1
//               ? Colors.black
//               : Colors.white, // Active: Black, Inactive: White
//         ),
//         user != null && user.photoURL != null
//             ? CircleAvatar(
//                 backgroundImage: NetworkImage(user.photoURL!),
//                 radius: 15, // Adjusted for better visibility
//               )
//             : Icon(
//                 Icons.account_circle,
//                 size: 30,
//                 color: selectedIndex == 2
//                     ? Colors.black
//                     : Colors.white, // Active: Black, Inactive: White
//               ),
//       ],
//     );
//   }
// }


class BottomNavigationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);
    final notifier = ref.read(bottomNavProvider.notifier);

    return Container(
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 8.0,
            color: Color(0xFF2C3E50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(context, icon: Icons.home, index: 0, currentIndex: currentIndex, onTap: notifier.setIndex),
                SizedBox(width: 48), // space for middle
                _navItem(context, icon: Icons.search, index: 1, currentIndex: currentIndex, onTap: notifier.setIndex),
                SizedBox(width: 48),
                _navItem(context, icon: Icons.person, index: 2, currentIndex: currentIndex, onTap: notifier.setIndex),
              ],
            ),
          ),
          Positioned(
            top: -15,
            left: MediaQuery.of(context).size.width / 6 * (currentIndex * 2 + 1) - 15,
            child: CustomPaint(
              size: Size(30, 30),
              painter: CurvePainter(),
            ),
          )
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, {
    required IconData icon,
    required int index,
    required int currentIndex,
    required void Function(int, BuildContext) onTap,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        color: currentIndex == index ? Colors.amber : Colors.white,
      ),
      onPressed: () => onTap(index, context),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width / 2, 0, size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
