// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/providers/user_provider.dart';
import 'package:flutter_ratemybites/resources/auth_methods.dart';
import 'package:flutter_ratemybites/responsive/mobile_screen_layout.dart';
import 'package:flutter_ratemybites/responsive/responsive_layout.dart';
import 'package:flutter_ratemybites/responsive/web_screen_layout.dart';
import 'package:flutter_ratemybites/screens/info_screen.dart';
import 'package:flutter_ratemybites/screens/signup_screen.dart';
import 'package:flutter_ratemybites/utilis/utils.dart';
import 'package:flutter_ratemybites/widgets/text_field_input.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  bool checkForm() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showSnackBar(context, "All fields must be filled");
      return false;
    }
    return true;
  }

  void signInUser() async {
    showLoading(context);
    String response = await AuthMethods().signInUser(
        email: _emailController.text, password: _passwordController.text);
    if (response == 'success') {
      Navigator.of(context).pop();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            newUser: false,
            welcomeScreen: InfoScreen(),
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
        (route) => false,
      );
    } else {
      Navigator.of(context).pop();
      showSnackBar(context, response);
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
                height: 50,
              ),
              const Text(
                "Sign In",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 30,
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://static.vecteezy.com/system/resources/thumbnails/005/129/844/small_2x/profile-user-icon-isolated-on-white-background-eps10-free-vector.jpg"),
                radius: 80,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Rate My Bites",
                style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.italic,
                  fontFamily: "Roboto",
                ),
              ),
              const SizedBox(
                height: 25,
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
                hintText: "Password",
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
                        signInUser();
                      }
                    },
                    icon: const Icon(Icons.navigate_next_sharp),
                    label: const Text("Sign In"),
                  ),
                ],
              ),
              const SizedBox(
                height: 60,
              ),
              Container(
                margin: EdgeInsets.only(bottom: 30),
                child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SignupScreen())),
                    child:
                        const Text("Don't have an account ? Sign Up instead.",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ))),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
