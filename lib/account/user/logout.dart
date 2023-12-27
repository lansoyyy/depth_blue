import 'package:flutter/material.dart';

import '../../extra/toast.dart';

Future<bool?> showLogoutConfirmationDialog(BuildContext context) async {
  bool? logoutConfirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              showToastOk('Successfully Logout');
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
  return logoutConfirmed;
}

