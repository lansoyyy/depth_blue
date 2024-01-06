import 'package:depthblue3/account/user/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../firebase/auth_service.dart';
import '../../screens/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool isSigningIn = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Blue wave design
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 200,
              child: CustomPaint(
                painter: WavePainter(),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 150),
                  child: const Center(
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Form(
                    child: Column(
                      children: <Widget>[
                        buildTextField('EMAIL', emailController),
                        const SizedBox(height: 20.0),
                        buildTextField('PASSWORD', passwordController,
                            obscureText: true),
                        const SizedBox(height: 5.0),
                        buildForgotPasswordLink(),
                        const SizedBox(height: 20.0),
                        buildLoginButton(authService),
                        const SizedBox(height: 20.0),
                        buildSignUpLink(),
                        // ... Remaining UI code
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller,
      {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  Widget buildForgotPasswordLink() {
    return Container(
      alignment: const Alignment(1.0, 0.0),
      padding: const EdgeInsets.only(top: 25.0, left: 20.0),
      child: const InkWell(
        child: Center(
          child: Text(
            'Forgot Password',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoginButton(AuthService authService) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      height: 40.0,
      child: Material(
        borderRadius: BorderRadius.circular(7.0),
        color: const Color.fromRGBO(81, 113, 100, 0.6),
        elevation: 0,
        child: isSigningIn
            ? const CircularProgressIndicator()
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    isSigningIn = true;
                  });

                  try {
                    await authService.signInWithEmailAndPassword(
                      emailController.text,
                      passwordController.text,
                    );
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const HomePage()));
                    // Handle successful sign-in
                  } catch (e) {
                    // Handle sign-in errors
                    if (kDebugMode) {
                      print('Error signing in: $e');
                    }
                  } finally {
                    setState(() {
                      isSigningIn = false;
                    });
                  }
                },
              ),
      ),
    );
  }

  Widget buildSignUpLink() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 25.0),
      child: InkWell(
        onTap: () {
          // Add navigation or action for sign up
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SignupPage(),
            ),
          );
        },
        child: const Text(
          'Don\'t have an account? Sign Up',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..lineTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.6,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.4,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
