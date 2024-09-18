// ignore_for_file: use_build_context_synchronously

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/providers/user_provider.dart';
import 'package:flutter_ratemybites/resources/firestore_methods.dart';
import 'package:flutter_ratemybites/utilis/utils.dart';
import 'package:flutter_ratemybites/widgets/text_field_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  String? _selectedRating;
  Uint8List? _file;
  bool _postReview = false;

  _selectImage(BuildContext parentContext) async {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Choose an option"),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text("Take a photo"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text("Choose from gallery"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                },
              ),
            ],
          );
        });
  }

  bool checkForm() {
    if (_locationController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedRating == null ||
        _reviewController.text.isEmpty ||
        _file == null) {
      showSnackBar(context, "All fields and image upload must be filled");
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    super.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _reviewController.dispose();
  }

  void makeAPost(String userID, String username, String profileURL) async {
    try {
      showLoading(context);
      String response = await FireStoreMethods().uploadPost(
          _locationController.text,
          _priceController.text,
          _selectedRating![0],
          _reviewController.text,
          _file!,
          userID,
          username,
          profileURL);
      if (response == 'success') {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierColor:
              Colors.transparent, // Set the barrier color to transparent
          builder: (context) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).secondaryHeaderColor,
                ),
                height: 200,
                width: 200,
                child: Center(
                    child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Posted !',
                      textStyle: const TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                      speed: const Duration(milliseconds: 500),
                    ),
                  ],
                  repeatForever: true,
                  pause: const Duration(milliseconds: 1000),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                )),
              ),
            );
          },
        );

        clearFields();
        setState(() {
          _postReview = false;
        });
      }
    } catch (e) {
      Navigator.of(context).pop();
      showSnackBar(context, e.toString());
    }
  }

  void clearFields() {
    setState(() {
      _locationController.clear();
      _priceController.clear();
      _reviewController.clear();
      _selectedRating = null;
      _file = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review"),
      ),
      body: SafeArea(
          child: _postReview
              ? SingleChildScrollView(
                  child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Column(
                    children: [
                      TextFieldInput(
                          textEditingController: _locationController,
                          hintText: "Restaurant Location",
                          textInputType: TextInputType.text),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFieldInput(
                        textEditingController: _priceController,
                        hintText: "Price (MYR)",
                        textInputType: const TextInputType.numberWithOptions(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            DropdownButton<String>(
                              hint:
                                  const Text("What's your rating for the dish"),
                              value:
                                  _selectedRating, // Set the value of the dropdown to the selected gender
                              items: <String>[
                                '1 star',
                                '2 star',
                                '3 star',
                                "4 star",
                                "5 star"
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                // Update the state with the selected gender
                                setState(() {
                                  _selectedRating = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _reviewController,
                        minLines: 3,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'What would you say about the dish ?',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              _file == null
                                  ? ElevatedButton.icon(
                                      onPressed: () {
                                        _selectImage(context);
                                      },
                                      icon:
                                          const Icon(Icons.upload_file_rounded),
                                      label: const Text("Upload photo"))
                                  : ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _file = null;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        "Delete Image",
                                        style: TextStyle(color: Colors.red),
                                      ))

                              // Use Image widget with MemoryImage
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                          height: 100,
                          width: 200,
                          child: _file != null ? Image.memory(_file!) : null),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                              onPressed: () {
                                if (checkForm()) {
                                  makeAPost(
                                      userProvider.getUser.userID,
                                      userProvider.getUser.username,
                                      userProvider.getUser.profileURL);
                                }
                              },
                              icon: const Icon(Icons.send),
                              label: const Text("Post")),
                        ],
                      ),
                    ],
                  ),
                ))
              : InkWell(
                  onTap: () {
                    setState(() {
                      _postReview = true;
                    });
                  },
                  child: const Scaffold(
                      body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("Post a review"), Icon(Icons.touch_app)],
                    ),
                  )),
                )),
    );
  }
}
