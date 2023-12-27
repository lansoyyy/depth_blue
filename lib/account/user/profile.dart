import 'package:flutter/material.dart';
import '../../firebase/auth_service.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;
  final AuthService authService = AuthService();

  ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder(
        future: authService.loadProfileData(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            var userData = snapshot.data as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: userData.containsKey('profileImageUrl')
                        ? NetworkImage(
                            getUserDataValue(userData, 'profileImageUrl'))
                        : const AssetImage('assets/misc/default.png')
                            as ImageProvider<Object>,
                  ),
                  const SizedBox(height: 16),
                  Text('Username: ${getUserDataValue(userData, 'username')}',
                      style: const TextStyle(fontSize: 18)),
                  Text(
                      'Name: ${getUserDataValue(userData, 'firstname')} ${getUserDataValue(userData, 'lastname')}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Gender: ${getUserDataValue(userData, 'gender')}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Phone: ${getUserDataValue(userData, 'phone')}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Email: ${getUserDataValue(userData, 'email')}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Location: ${getUserDataValue(userData, 'location')}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                              userData: userData, userId: userId),
                        ),
                      );
                    },
                    child: const Text('Edit Profile'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Implement logout logic here
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
