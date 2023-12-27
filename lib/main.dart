import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'account/user/login.dart';
import 'account/user/register.dart';
import 'extra/theme.dart';
import 'extra/wrapper.dart';
import 'firebase/auth_service.dart';
import 'firebase/firebase_options.dart';

const String appTitle = 'DepthBlue';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: const DepthBlue(),
    ),
  );
}

class DepthBlue extends StatelessWidget {
  const DepthBlue({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('en')],
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const Wrapper(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const SignupPage(),
      },
    );
  }
}
