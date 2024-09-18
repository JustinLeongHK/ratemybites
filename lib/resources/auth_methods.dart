import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ratemybites/models/user.dart' as model;
import 'package:flutter_ratemybites/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signUpUser(
      {required String email,
      required String password,
      Uint8List? file,
      required String username}) async {
    late String profileURL;
    String response = "success";

    try {
      // register user to firebase authentication with email and password
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // Save user profile image if not null
      if (file != null) {
        profileURL =
            await StorageMethods().uploadImageToStorage("Profile", file, false);
      } else {
        profileURL =
            "https://static.vecteezy.com/system/resources/thumbnails/005/129/844/small_2x/profile-user-icon-isolated-on-white-background-eps10-free-vector.jpg";
      }

      model.User user = model.User(
          gender: "",
          age: "",
          email: email,
          userID: credential.user!.uid,
          profileURL: profileURL,
          username: username,
          bio: "",
          followers: [],
          following: [],
          saved: []);

      // add user to firestore
      await _firestore
          .collection("Users")
          .doc(credential.user!.uid)
          .set(user.toJson());
    } catch (e) {
      response = e.toString();
    }
    return response;
  }

  Future<String> signInUser(
      {required String email, required String password}) async {
    String response = "success";
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      return e.toString();
    }
    return response;
  }

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('Users').doc(currentUser.uid).get();
    return model.User.fromSnap(documentSnapshot);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // Wait for authentication state to change
    await FirebaseAuth.instance
        .authStateChanges()
        .firstWhere((user) => user == null);
  }
}
