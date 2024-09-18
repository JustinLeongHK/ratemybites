// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/providers/user_provider.dart';
import 'package:flutter_ratemybites/resources/auth_methods.dart';
import 'package:flutter_ratemybites/responsive/mobile_screen_layout.dart';
import 'package:flutter_ratemybites/responsive/responsive_layout.dart';
import 'package:flutter_ratemybites/responsive/web_screen_layout.dart';
import 'package:flutter_ratemybites/screens/signin_screen.dart';
import 'package:flutter_ratemybites/screens/info_screen.dart';
import 'package:flutter_ratemybites/utilis/utils.dart';
import 'package:flutter_ratemybites/widgets/text_field_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  Uint8List? _image;

  // select image from gallary
  selectImage() async {
    Uint8List imageFromGallary = await pickImage(ImageSource.gallery);
    setState(() {
      _image = imageFromGallary;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  bool checkForm() {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      showSnackBar(context, "All fields must be filled");
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      showSnackBar(context, "Passwords do not match");
      return false;
    }
    if (_passwordController.text.length < 7) {
      showSnackBar(context, "Password must be at least 7 characters");
      return false;
    }
    return true;
  }

  void signUpUser() async {
    showLoading(context);
    String response = await AuthMethods().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        file: _image);

    if (response != "success") {
      Navigator.of(context).pop();
      showSnackBar(context, response);
    } else {
      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
                mobileScreenLayout: MobileScreenLayout(),
                webScreenLayout: WebScreenLayout(),
                welcomeScreen: InfoScreen(),
                newUser: true),
          ),
          (route) => false, // Always return false to remove all routes
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Sign Up",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 25,
              ),
              Stack(children: [
                CircleAvatar(
                  radius: 64,
                  backgroundImage: _image != null
                      ? MemoryImage(_image!) as ImageProvider
                      : const NetworkImage(
                              "https://static.vecteezy.com/system/resources/thumbnails/005/129/844/small_2x/profile-user-icon-isolated-on-white-background-eps10-free-vector.jpg")
                          as ImageProvider,
                ),
                Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: () => selectImage(),
                      icon: _image == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 40,
                            )
                          : InkWell(
                              onTap: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                              child: const Icon(
                                Icons.delete,
                                size: 40,
                                color: Colors.red,
                              ),
                            ),
                      color: Colors.blue,
                    ))
              ]),
              const SizedBox(
                height: 30,
              ),
              TextFieldInput(
                textEditingController: _usernameController,
                hintText: "Username",
                textInputType: TextInputType.text,
              ),
              const SizedBox(
                height: 24,
              ),
              TextFieldInput(
                textEditingController: _emailController,
                hintText: "Email",
                textInputType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 24,
              ),
              TextFieldInput(
                textEditingController: _passwordController,
                hintText: "Password  (7 characters or more)",
                isPassword: true,
                textInputType: TextInputType.text,
              ),
              const SizedBox(
                height: 24,
              ),
              TextFieldInput(
                textEditingController: _confirmPasswordController,
                hintText: "Confirm Password  (7 characters or more)",
                isPassword: true,
                textInputType: TextInputType.text,
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (checkForm()) {
                        signUpUser();
                      }
                    },
                    icon: const Icon(Icons.navigate_next_sharp),
                    label: const Text("Sign Up"),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SignInScreen())),
                  child: const Text("Already have an account ? Log In instead.",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      )))
            ],
          ),
        ),
      )),
    );
  }
}
