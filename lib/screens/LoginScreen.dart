import 'ProfileScreen.dart';
import '../widgets/AuthWidget.dart';
import '../widgets/BottomNavigationWidget.dart';
import 'package:flutter/material.dart';
import '../widgets/GoogleButtonWidgte.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
          ), // Responsive padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Title Text
              Container(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
                child: Text(
                  'Log In to Your Account to\nAccess our Exclusive Content',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, // Responsive font size
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ), // Space between text and button

              RoundedButtonWithImage(
                image: AssetImage('lib/assets/image/Google_Logo.png'),
                text: 'Continue with Google',
                onPressed: () async {
                  final user = await _auth.signInWithGoogle();
                  if (user != null) {
                    print('Google Sign-In Successful: ${user.email}');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          userName: user.displayName ?? '',
                          userImage: user.photoURL ??
                              'https://via.placeholder.com/150',
                        ),
                      ),
                    );
                  } else {
                    print('Google Sign-In Failed');
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(),
    );
  }
}
