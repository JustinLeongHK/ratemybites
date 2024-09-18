import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/widgets/post_card.dart';

class SavedPostScreen extends StatelessWidget {
  const SavedPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text("Saved Post"),
              pinned: false,
              floating: true,
            ),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text('An error occurred'),
                    ),
                  );
                }

                var userData = snapshot.data!.data();
                List<dynamic> savedPostIds = userData?['saved'] ?? [];

                if (savedPostIds.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No saved posts',
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return FutureBuilder<
                          DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection('Posts')
                            .doc(savedPostIds[index])
                            .get(),
                        builder: (context, postSnapshot) {
                          if (postSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          var postData = postSnapshot.data!.data();
                          return PostCard(snap: postData);
                        },
                      );
                    },
                    childCount: savedPostIds.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
