import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ratemybites/firebase_options.dart';
import 'package:flutter_ratemybites/providers/user_provider.dart';
import 'package:flutter_ratemybites/responsive/mobile_screen_layout.dart';
import 'package:flutter_ratemybites/responsive/responsive_layout.dart';
import 'package:flutter_ratemybites/responsive/web_screen_layout.dart';
import 'package:flutter_ratemybites/screens/info_screen.dart';
import 'package:flutter_ratemybites/screens/signin_screen.dart';
import 'package:flutter_ratemybites/theme/dark_mode.dart';
import 'package:flutter_ratemybites/theme/light_mode.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rate My Bites',
        theme: lightmode,
        darkTheme: darkMode,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // authentication state is being fetched
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              // it has received at least one value
              if (snapshot.hasData) {
                //  the stream emits an event with authentication data means user is logged in
                return const ResponsiveLayout(
                    welcomeScreen: InfoScreen(),
                    newUser: false,
                    mobileScreenLayout: MobileScreenLayout(),
                    webScreenLayout: WebScreenLayout());
              }
            }
            // the stream emits an event with no authentication data means user is not logged in
            return const SignInScreen();
          },
        ),
      ),
    );
  }
}
