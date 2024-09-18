// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/models/user.dart' as model;
import 'package:flutter_ratemybites/providers/user_provider.dart';
import 'package:flutter_ratemybites/resources/firestore_methods.dart';
import 'package:flutter_ratemybites/screens/comments_screen.dart';
import 'package:flutter_ratemybites/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCard extends StatefulWidget {
  final dynamic snap;

  const PostCard({required this.snap, super.key});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final userID = FirebaseAuth.instance.currentUser!.uid;
  final ScreenshotController screenshotController = ScreenshotController();

  void _savePost(String postID, String userID, List saved) async {
    await FireStoreMethods().savePost(postID, userID, saved);
  }

  void _toggleLike(String postID, String userID, List likes) async {
    await FireStoreMethods().likePost(postID, userID, likes);
    setState(() {
      if (likes.contains(userID)) {
        likes.remove(userID); // Remove userID if already liked
      } else {
        likes.add(userID); // Add userID if not liked
      }
    });
  }

  void _manageFollowers(String userID, String followID) async {
    await FireStoreMethods().followUser(userID, followID);
  }

  List<Icon> buildStarIcons(int count) {
    return List.generate(
      count,
      (index) => Icon(
        Icons.star,
        color: Colors.yellow[600],
      ),
    );
  }

  Future<void> _launchGoogleMaps(String searchQuery) async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$searchQuery');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _sharePressed() async {
    try {
      final capturedImage = await screenshotController.captureFromWidget(
        Material(
          child: PostCard(snap: widget.snap),
        ),
      );

      final XFile xFile = XFile.fromData(capturedImage, name: 'screenshot.jpg');

      await Share.shareXFiles([xFile], text: 'Great picture');
      print('Screenshot shared successfully!');
    } catch (e) {
      print('Error sharing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing screenshot: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context).refreshUser();
    final model.User user = Provider.of<UserProvider>(context).getUser;
    // String extractedDigits =
    //     widget.snap['rating'].replaceAll(RegExp(r'[^0-9]'), '');
    List<Icon> starIcons = buildStarIcons(widget.snap['rating']);

    return Container(
      decoration: BoxDecoration(
        border: const Border(
          bottom: BorderSide(width: 5),
          top: BorderSide(width: 2),
          left: BorderSide(width: 2),
          right: BorderSide(width: 5),
        ),
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).highlightColor,
      ),
      width: 500,
      height: 450,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            userID: widget.snap['userID'],
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.snap['profileURL']),
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(widget.snap['username']),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: widget.snap['userID'] != userID
                        ? InkWell(
                            onTap: () async {
                              _manageFollowers(userID, widget.snap['userID']);
                              await Provider.of<UserProvider>(context,
                                      listen: false)
                                  .refreshUser();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).secondaryHeaderColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text(
                                user.following.contains(widget.snap['userID'])
                                    ? "Unfollow"
                                    : "Follow User",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(widget.snap['likes'].length.toString()),
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: () => _toggleLike(
                        widget.snap['postID'], userID, widget.snap['likes']),
                    child: Icon(
                      Icons.favorite_outlined,
                      color: widget.snap['likes'].contains(userID)
                          ? Colors.red
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 200,
            width: 400,
            decoration: BoxDecoration(
              border: Border.all(width: 3),
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(widget.snap['postURL']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).secondaryHeaderColor,
                    border: Border.all(width: 1)),
                child: Text(
                  "MYR ${widget.snap['price']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).secondaryHeaderColor,
                ),
                child: Row(
                  children: starIcons,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: Text(
                widget.snap['review'],
                style: TextStyle(fontSize: 12),
              )),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _launchGoogleMaps(widget.snap['location']),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      color: Theme.of(context).secondaryHeaderColor,
                      borderRadius: BorderRadius.circular(5)),
                  padding: const EdgeInsets.only(left: 5),
                  child: const Row(
                    children: [
                      Text(
                        "Get it Here -",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          decorationColor: Colors.white,
                          decorationThickness: 2.0,
                        ),
                      ),
                      Icon(
                        Icons.navigation_rounded,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () =>
                        _savePost(widget.snap['postID'], userID, user.saved),
                    child: Icon(
                      Icons.save,
                      color: user.saved.contains(widget.snap['postID'])
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _sharePressed,
                    child: const Icon(Icons.share),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(
                            postID: widget.snap['postID'],
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.comment),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
