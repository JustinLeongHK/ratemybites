import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String location;
  final String price;
  final String rating;
  final String review;
  final String userID;
  final String username;
  final likes;
  final String postID;
  final DateTime datePublished;
  final String postURL;
  final String profileURL;

  const Post(
      {required this.location,
      required this.price,
      required this.rating,
      required this.review,
      required this.userID,
      required this.username,
      required this.likes,
      required this.postID,
      required this.datePublished,
      required this.postURL,
      required this.profileURL});

  // read form firestore
  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Post(
        location: snapshot['location'],
        price: snapshot['price'],
        rating: snapshot['rating'],
        review: snapshot['review'],
        userID: snapshot['userID'],
        username: snapshot['username'],
        likes: snapshot['likes'],
        postID: snapshot['postID'],
        datePublished: snapshot['datePublished'],
        postURL: snapshot['postURL'],
        profileURL: snapshot['profileURL']);
  }

  // post to firestore
  Map<String, dynamic> toJson() => {
        'location': location,
        'price': int.parse(price),
        'rating': int.parse(rating),
        'review': review,
        'userID': userID,
        'likes': likes,
        'username': username,
        'postID': postID,
        'datePublished': datePublished,
        'postURL': postURL,
        'profileURL': profileURL
      };
}
