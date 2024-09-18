// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/providers/user_provider.dart';
import 'package:flutter_ratemybites/resources/firestore_methods.dart';
import 'package:flutter_ratemybites/responsive/mobile_screen_layout.dart';
import 'package:flutter_ratemybites/utilis/utils.dart';
import 'package:provider/provider.dart';

class BioScreen extends StatefulWidget {
  final String? userID;
  const BioScreen({this.userID, super.key});

  @override
  State<BioScreen> createState() => _BioScreenState();
}

class _BioScreenState extends State<BioScreen> {
  final TextEditingController _aboutMeController = TextEditingController();
  String? _selectedAge;
  String? _selectedGender;
  bool _updatedBio = false;
  var userData = {};

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    if (widget.userID != null) {
      try {
        var userSnap = await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userID)
            .get();
        userData = userSnap.data()!;
        setState(() {
          _aboutMeController.text = userData['bio'];
          _selectedGender =
              userData['gender'] != "" ? userData['gender'] : null;
          _selectedAge = userData['age'] != "" ? userData['age'] : null;
        });
      } catch (e) {
        showSnackBar(context, e.toString());
      }
    }
  }

  List<String> ages() {
    List<String> ages = [];
    for (int age = 18; age <= 100; age++) {
      ages.add(age.toString());
    }
    return ages;
  }

  bool checkForm() {
    if (_selectedAge == null ||
        _selectedGender == null ||
        _aboutMeController.text.isEmpty) {
      showSnackBar(context, "All fields must be filled");
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    super.dispose();
    _aboutMeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("About You"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Text("Gender"),
                  const SizedBox(
                    width: 50,
                  ),
                  DropdownButton<String>(
                    hint: const Text("What is your gender ?"),
                    value:
                        _selectedGender, // Set the value of the dropdown to the selected gender
                    items: <String>['Female', 'Male'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      // Update the state with the selected gender
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  const Text("Age"),
                  const SizedBox(
                    width: 70,
                  ),
                  DropdownButton<String>(
                    hint: const Text("What is your age ?"),
                    value: _selectedAge,
                    items: ages().map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedAge = newValue;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              const Text("Populate your profile with some information"),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _aboutMeController,
                minLines: 3,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tell us about you...',
                ),
              ),
              const SizedBox(
                height: 120,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                    ),
                  ),
                  ElevatedButton.icon(
                      onPressed: () async {
                        if (checkForm()) {
                          if (_updatedBio) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MobileScreenLayout(),
                              ),
                              (route) =>
                                  false, // Set the predicate to always return false to remove all routes
                            );
                            return;
                          }
                          String response = await FireStoreMethods().updateBio(
                              _selectedAge!,
                              _selectedGender!,
                              _aboutMeController.text,
                              userProvider.getUser.userID);
                          if (response != 'success') {
                            showSnackBar(context, response);
                          }
                          showSnackBar(context, "Bio Updated !");
                          setState(() {
                            _updatedBio = true;
                          });
                        }
                      },
                      icon: const Icon(Icons.navigate_next_outlined),
                      label: _updatedBio
                          ? const Text("Finish")
                          : const Text("Update")),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}
