import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ratemybites/models/post.dart';
import 'package:flutter_ratemybites/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
      String location,
      String price,
      String rating,
      String review,
      Uint8List file,
      String userID,
      String username,
      String profileURL) async {
    String response = 'success';
    try {
      // post the image of the post to storage
      String postURL =
          await StorageMethods().uploadImageToStorage('Posts', file, true);
      String postID = const Uuid().v1();
      Post post = Post(
        location: location,
        price: price,
        rating: rating,
        review: review,
        userID: userID,
        username: username,
        likes: [],
        postID: postID,
        datePublished: DateTime.now(),
        postURL: postURL,
        profileURL: profileURL,
      );

      // the post to firestore with unique postID for each post
      _firestore.collection('Posts').doc(postID).set(post.toJson());
    } catch (e) {
      response = e.toString();
    }
    return response;
  }

  Future<String> updateBio(
      String age, String gender, String aboutMe, String userID) async {
    String response = "success";
    try {
      await _firestore
          .collection('Users')
          .doc(userID)
          .update({"age": age, 'gender': gender, 'bio': aboutMe});
    } catch (e) {
      response = e.toString();
    }
    return response;
  }

  Future<String> deletePost(String postID) async {
    String response = "success";
    try {
      await _firestore.collection('Posts').doc(postID).delete();
    } catch (e) {
      response = e.toString();
    }
    return response;
  }

  Future<String> postComment(String postID, String comment, String userID,
      String username, String profileURL) async {
    String response = 'success';
    try {
      String commentID = const Uuid().v1();
      _firestore
          .collection('Posts')
          .doc(postID)
          .collection('Comments')
          .doc(commentID)
          .set({
        'profileURL': profileURL,
        'username': username,
        'userID': userID,
        'comment': comment,
        'commentID': commentID,
        'datePublished': DateTime.now()
      });
    } catch (e) {
      response = e.toString();
    }
    return response;
  }

  Future<String> likePost(String postID, String userID, List likes) async {
    String response = "Success";
    try {
      if (likes.contains(userID)) {
        _firestore.collection('Posts').doc(postID).update({
          'likes': FieldValue.arrayRemove([userID])
        });
      } else {
        _firestore.collection('Posts').doc(postID).update({
          'likes': FieldValue.arrayUnion([userID])
        });
      }
    } catch (e) {
      response = e.toString();
    }
    return response;
  }

  Future<String> savePost(String postID, String userID, List saved) async {
    String response = "Success";
    try {
      if (saved.contains(postID)) {
        _firestore.collection("Users").doc(userID).update({
          "saved": FieldValue.arrayRemove([postID])
        });
      } else {
        _firestore.collection("Users").doc(userID).update({
          "saved": FieldValue.arrayUnion([postID])
        });
      }
    } catch (e) {
      response = e.toString();
    }
    return response;
  }

  Future<String> followUser(String userID, String followID) async {
    String response = "Success";
    try {
      DocumentSnapshot snap =
          await _firestore.collection('Users').doc(userID).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followID)) {
        await _firestore.collection('Users').doc(followID).update({
          'followers': FieldValue.arrayRemove([userID])
        });

        await _firestore.collection('Users').doc(userID).update({
          'following': FieldValue.arrayRemove([followID])
        });
      } else {
        await _firestore.collection('Users').doc(followID).update({
          'followers': FieldValue.arrayUnion([userID])
        });

        await _firestore.collection('Users').doc(userID).update({
          'following': FieldValue.arrayUnion([followID])
        });
      }
    } catch (e) {
      response = e.toString();
    }
    return response;
  }
}
