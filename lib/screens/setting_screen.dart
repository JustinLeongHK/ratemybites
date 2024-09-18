import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/resources/auth_methods.dart';
import 'package:flutter_ratemybites/screens/bio_screen.dart';
import 'package:flutter_ratemybites/screens/signin_screen.dart';

class SettingScreen extends StatelessWidget {
  final String userID;
  const SettingScreen({required this.userID, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: const Text("Update Biography"),
            onTap: () {
              if (context.mounted) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => BioScreen(
                          userID: userID,
                        )));
              }
            },
          ),
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: ((BuildContext context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to log out ?"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel")),
                        TextButton(
                          onPressed: () async {
                            // Close the dialog
                            Navigator.of(context).pop();

                            // logout
                            await AuthMethods().signOut();

                            // change screen
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SignInScreen()));
                            }
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      ],
                    );
                  }));
            },
            child: const ListTile(
              leading: Icon(Icons.logout),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: Text("Logout"),
            ),
          )
        ],
      ),
    );
  }
}
