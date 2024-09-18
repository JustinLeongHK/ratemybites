import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/widgets/post_card.dart';

class SinglePost extends StatelessWidget {
  final snap;
  const SinglePost({required this.snap, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: PostCard(snap: snap)),
    );
  }
}
