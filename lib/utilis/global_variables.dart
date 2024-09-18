import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_ratemybites/screens/addpost_screen.dart';
import 'package:flutter_ratemybites/screens/home_screen.dart';
import 'package:flutter_ratemybites/screens/profile_screen.dart';
import 'package:flutter_ratemybites/screens/savedpost_screen.dart';
import 'package:flutter_ratemybites/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> get homeScreenWidgets {
  final currentUserID = FirebaseAuth.instance.currentUser?.uid ?? '';
  return [
    const HomeScreen(),
    const SearchScreen(),
    const AddPostScreen(),
    const SavedPostScreen(),
    ProfileScreen(userID: currentUserID),
  ];
}
