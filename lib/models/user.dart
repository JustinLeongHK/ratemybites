import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String gender;
  final String age;
  final String email;
  final String userID;
  final String profileURL;
  final String username;
  final String bio;
  final List followers;
  final List following;
  final List saved;

  const User(
      {required this.gender,
      required this.age,
      required this.email,
      required this.userID,
      required this.profileURL,
      required this.username,
      required this.bio,
      required this.followers,
      required this.following,
      required this.saved});

  Map<String, dynamic> toJson() => {
        'gender': gender,
        'age': age,
        "username": username,
        'userID': userID,
        'email': email,
        'profileURL': profileURL,
        'bio': bio,
        'followers': followers,
        "following": following,
        'saved': saved
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
        gender: snapshot['gender'],
        age: snapshot['age'],
        email: snapshot['email'],
        userID: snapshot['userID'],
        profileURL: snapshot['profileURL'],
        username: snapshot['username'],
        bio: snapshot['bio'],
        followers: snapshot['followers'],
        following: snapshot['following'],
        saved: snapshot['saved']);
  }
}
