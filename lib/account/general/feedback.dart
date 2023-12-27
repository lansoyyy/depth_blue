import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../extra/toast.dart';

class FeedbackHandler {
  static void handleFeedback(BuildContext context, String userUid) {
    TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Feedback or Report'),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                const Text(
                    'We value your feedback! Please share your thoughts:'),
                TextField(
                  controller: feedbackController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Type your feedback here...',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (feedbackController.text.isNotEmpty) {
                  saveFeedbackToFirebase(userUid, feedbackController.text);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feedback cannot be empty!'),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  static void saveFeedbackToFirebase(String userUid, String feedback) {
    CollectionReference userFeedbackCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(userUid)
        .collection('feedbacks');

    userFeedbackCollection.add({
      'feedback': feedback,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((value) {
      showToastOk('Feedback submitted successfully!');
    }).catchError((error) {
      showToastErr('Error submitting feedback: $error');
    });
  }
}
