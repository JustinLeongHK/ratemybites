// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/providers/user_provider.dart';
import 'package:flutter_ratemybites/resources/firestore_methods.dart';
import 'package:flutter_ratemybites/utilis/utils.dart';
import 'package:flutter_ratemybites/widgets/comment_card.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final String postID;
  const CommentsScreen({required this.postID, super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void postComment(String userID, String username, String profileURL) async {
    if (_commentController.text.trim().isEmpty) {
      showSnackBar(context, 'Comment cannot be empty');
      return;
    }
    try {
      await FireStoreMethods().postComment(
        widget.postID,
        _commentController.text,
        userID,
        username,
        profileURL,
      );
      _commentController.clear();
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.getUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Posts")
                .doc(widget.postID)
                .collection('Comments')
                .orderBy('datePublished', descending: false)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return const Center(child: CircularProgressIndicator());
              // }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading comments'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No comments yet'));
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) => CommentCard(
                  snap: snapshot.data!.docs[index],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: 5,
          right: 5,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.profileURL),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(8),
                  border: const OutlineInputBorder(),
                  hintText: 'Comment as ${user.username}...',
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () =>
                  postComment(user.userID, user.username, user.profileURL),
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
