import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../extra/toast.dart';

String getUserDataValue(Map<String, dynamic> userData, String key) {
  return userData.containsKey(key) ? userData[key].toString() : '';
}

class User {
  final String uid;
  final String? email;

  User(this.uid, this.email);
}

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('Users');

  User? _userFromFirebase(auth.User? user) {
    if (user == null) {
      return null;
    }
    return User(user.uid, user.email);
  }

  Stream<User?>? get user {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  Future<User?> getCurrentUser() async {
    auth.User? user = _firebaseAuth.currentUser;
    return _userFromFirebase(user);
  }

  Future<Map<String, dynamic>> loadProfileData(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await _usersCollection.doc(userId).get();

      return userSnapshot.exists
          ? {
              'username': userSnapshot['username'],
              'firstname': userSnapshot['firstname'],
              'lastname': userSnapshot['lastname'],
              'gender': userSnapshot['gender'],
              'phone': userSnapshot['phone'],
              'email': userSnapshot['email'],
              'location': userSnapshot['location'],
            }
          : {};
    } catch (e) {
      showToastErr('Error loading profile data');
      return {};
    }
  }

  Future<void> updateProfileData(
      String userId, Map<String, dynamic> updatedData) async {
    try {
      // Use FirebaseFirestore to update the user's profile data
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update(updatedData);
      showToastOk('Profile data updated successfully');
    } catch (e) {
      showToastErr('Error updating profile data');
      // Handle the error as needed (show a message to the user, log it, etc.)
      throw Exception('Error updating profile data');
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    showToastOk('Login Successfully!');
    return _userFromFirebase(credential.user);
  }

  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
    String confirmPassword,
  ) async {
    if (password != confirmPassword) {
      throw Exception('Password and confirm password do not match');
    }

    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _usersCollection.doc(credential.user?.uid).set({
      'username': '',
      'firstname': '',
      'lastname': '',
      'email': email,
      'phone': '',
      'gender': '',
      'location': '',
      'password': password,
      'register date': FieldValue.serverTimestamp(),
    });

    showToastOk('Signup Successfully!');

    return _userFromFirebase(credential.user);
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

    if (googleSignInAccount == null) {
      showToastErr('User canceled Google Sign In');
      return null;
    }

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final auth.UserCredential authResult =
        await _firebaseAuth.signInWithCredential(credential);

    return _userFromFirebase(authResult.user);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
