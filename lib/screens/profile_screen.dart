import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ratemybites/models/user.dart' as model;
import 'package:flutter_ratemybites/providers/user_provider.dart';
import 'package:flutter_ratemybites/resources/firestore_methods.dart';
import 'package:flutter_ratemybites/screens/setting_screen.dart';
import 'package:flutter_ratemybites/screens/singlepost_screen.dart';
import 'package:flutter_ratemybites/utilis/utils.dart';
import 'package:flutter_ratemybites/widgets/count_text.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final String userID;

  ProfileScreen({super.key, String? userID})
      : userID = userID ?? FirebaseAuth.instance.currentUser!.uid;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = <String, dynamic>{};
  List<Map<String, dynamic>> postData = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      // Get the user details
      var userSnap = await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.userID)
          .get();
      if (userSnap.exists) {
        setState(() {
          userData = userSnap.data()!;
        });
      } else {
        throw 'User data not found';
      }

      // Get the user's post details
      var postSnap = await FirebaseFirestore.instance
          .collection("Posts")
          .where("userID", isEqualTo: widget.userID)
          .get();

      setState(() {
        postData = postSnap.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void _manageFollowers(String userID, String followID) async {
    await FireStoreMethods().followUser(userID, followID);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context).refreshUser();
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      body: SafeArea(
        child: userData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    leading:
                        FirebaseAuth.instance.currentUser!.uid != widget.userID
                            ? IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            : null,
                    expandedHeight: 220,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: const Border(
                            bottom: BorderSide(width: 5),
                            top: BorderSide(width: 2),
                            left: BorderSide(width: 2),
                            right: BorderSide(width: 5),
                          ),
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const SizedBox(height: 100),
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      NetworkImage(userData['profileURL']),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context).highlightColor,
                                  ),
                                  child: Text(
                                    userData['username'][0]
                                            .toString()
                                            .toUpperCase() +
                                        userData['username'].substring(1),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                const Spacer(),
                                CountText(
                                    count: postData.length.toString(),
                                    text: "Post"),
                                CountText(
                                  count: userData['following'] != null
                                      ? userData['following'].length.toString()
                                      : '',
                                  text: "Following",
                                ),
                                CountText(
                                  count: userData['followers'] != null
                                      ? userData['followers'].length.toString()
                                      : '',
                                  text: "Followers",
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1),
                                    color: Theme.of(context).highlightColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: userData['gender'] == 'Male'
                                      ? const Icon(Icons.boy,
                                          color: Colors.blue)
                                      : const Icon(Icons.girl,
                                          color: Colors.pink),
                                ),
                                const SizedBox(width: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1),
                                    color: Theme.of(context).highlightColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text("Age : ${userData['age']}"),
                                ),
                                const SizedBox(height: 5),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1),
                                    color: Theme.of(context).highlightColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    "${userData['bio']}",
                                    style: const TextStyle(fontSize: 8),
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (FirebaseAuth
                                            .instance.currentUser!.uid !=
                                        widget.userID)
                                      InkWell(
                                          onTap: () async {
                                            _manageFollowers(
                                                user.userID, widget.userID);
                                            await Provider.of<UserProvider>(
                                                    context,
                                                    listen: false)
                                                .refreshUser();
                                            getData();
                                          },
                                          child: user.following
                                                  .contains(widget.userID)
                                              ? const Icon(
                                                  Icons.person_remove_alt_1,
                                                  color: Colors.red,
                                                )
                                              : const Icon(Icons.person_add)),
                                    const SizedBox(width: 20),
                                    if (FirebaseAuth
                                            .instance.currentUser!.uid ==
                                        widget.userID)
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SettingScreen(
                                                      userID:
                                                          userData['userID']),
                                            ),
                                          );
                                        },
                                        child: const Icon(Icons.settings),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    pinned: true,
                    floating: false,
                    snap: false,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SinglePost(snap: postData[index]),
                                ),
                              );
                            },
                            child: GridTile(
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 2.0),
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            postData[index]['postURL']),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 5,
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Delete Post"),
                                              content: const Text(
                                                  "Are you sure you want to delete this post?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    // Delete the post from Firestore
                                                    await FireStoreMethods()
                                                        .deletePost(
                                                            postData[index]
                                                                ['postID']);
                                                    // Remove the deleted post from the local list
                                                    setState(() {
                                                      postData.removeAt(index);
                                                    });
                                                    // Close the dialog
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Icon(
                                        Icons.more_vert,
                                        color: Theme.of(context).primaryColor,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: postData.length,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
