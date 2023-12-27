// import 'package:flutter/material.dart';
//
//
// class NotificationSettingsPage extends StatefulWidget {
//   const NotificationSettingsPage({super.key});
//
//   @override
//   State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
// }
//
// class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
//   bool _enableNotifications = true;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notification Settings'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Enable Notifications'),
//             Switch(
//               value: _enableNotifications,
//               onChanged: (value) {
//                 setState(() {
//                   _enableNotifications = value;
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
