import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../firebase/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white24,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 30),
                child: const Center(
                  child: Text('Create an account',
                      style: TextStyle(
                          fontSize: 30.0, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          Container(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'EMAIL',
                    labelStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'PASSWORD ',
                    labelStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'CONFIRM PASSWORD',
                    labelStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30.0),
                Container(
                  width: 270,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.0),
                    color: const Color.fromRGBO(81, 113, 100, 0.8),
                  ),
                  child: ElevatedButton(
                    child: const Center(
                      child: Text(
                        'Signup',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      await authService.createUserWithEmailAndPassword(
                        emailController.text,
                        passwordController.text,
                        confirmPasswordController.text,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      } else {
                        return;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: Stack(
              children: <Widget>[
                const Text('___________',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black38)),
                Container(
                  padding: const EdgeInsets.only(left: 105, top: 10),
                  child: const Text('or continue with',
                      style: TextStyle(fontSize: 15.0, color: Colors.black38)),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 220),
                  child: const Text('__________',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38)),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 70),
                  child: Container(
                    width: 130,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.0),
                      color: const Color.fromRGBO(81, 113, 100, 0.2),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(top: 7, bottom: 7),
                      child: Image.asset('assets/logo/google.png'),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 70, left: 170),
                  child: Container(
                    width: 130,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.0),
                      color: const Color.fromRGBO(81, 113, 100, 0.2),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Image.asset('assets/logo/facebook.png'),
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
}
