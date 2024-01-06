import 'package:depthblue3/account/general/privacy_policy.dart';
import 'package:depthblue3/account/user/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../extra/theme.dart';
import '../../firebase/auth_service.dart';
import '../user/profile.dart';
import 'feedback.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isDarkMode = false;
  bool loading = false;
  bool _isMounted = true;

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    User? currentUser;

    return FutureBuilder<User?>(
      future: authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          currentUser = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
              actions: [
                IconButton(
                  icon: isDarkMode
                      ? const Icon(Icons.nightlight_round, color: Colors.black)
                      : const Icon(Icons.wb_sunny, color: Colors.white),
                  onPressed: () {
                    final themeProvider =
                        Provider.of<ThemeProvider>(context, listen: false);
                    themeProvider.toggleTheme();
                    setState(() {
                      isDarkMode = !isDarkMode;
                    });
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 15),
                  buildSettingsItem('Profile', Icons.person, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(userId: currentUser!.uid),
                      ),
                    );
                  }),
                  const SizedBox(height: 15),
                  buildSettingsItem('Security', Icons.security, () {}),
                  const SizedBox(height: 20),
                  const Text(
                    'General Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 15),
                  buildSettingsItem('Notification', Icons.notifications, () {}),
                  const Divider(),
                  buildSettingsItem('Feedback', Icons.feedback, () async {
                    FeedbackHandler.handleFeedback(context, currentUser!.uid);
                  }),
                  const Divider(),
                  buildSettingsItem('Privacy Policy', Icons.privacy_tip, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrivacyPolicy()),
                    );
                  }),
                  const Divider(),
                  buildSettingsItem('About Us', Icons.info, () {
                    showAboutDialog(
                        context: context, applicationVersion: 'version 1.0.0');
                  }),
                  const Divider(),
                  buildSettingsItem('Logout', Icons.exit_to_app, () async {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text(
                                'Logout Confirmation',
                                style: TextStyle(
                                    fontFamily: 'QBold',
                                    fontWeight: FontWeight.bold),
                              ),
                              content: const Text(
                                'Are you sure you want to Logout?',
                                style: TextStyle(fontFamily: 'QRegular'),
                              ),
                              actions: <Widget>[
                                MaterialButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Close',
                                    style: TextStyle(
                                        fontFamily: 'QRegular',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () async {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage()));
                                  },
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(
                                        fontFamily: 'QRegular',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ));
                  }),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildSettingsItem(
      String title, IconData iconData, VoidCallback onPressed) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          size: 20.0,
        ),
      ),
      onTap: onPressed,
    );
  }
}
