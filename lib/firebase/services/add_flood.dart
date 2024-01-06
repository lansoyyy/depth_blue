import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addFlood(name, email, img, lat, long) async {
  final docUser = FirebaseFirestore.instance.collection('Floods').doc();

  final json = {
    'img': img,
    'status': 'Low',
    'name': name,
    'email': email,
    'userId': FirebaseAuth.instance.currentUser!.uid,
    'dateTime': DateTime.now(),
    'lat': lat,
    'long': long,
    'type': 'Pending'
  };

  await docUser.set(json);
}
