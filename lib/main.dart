import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebase_listin/_core/my_colors.dart';
import 'package:flutter_firebase_listin/authentication/screens/auth_screen.dart';
import 'package:flutter_firebase_listin/firestore/presentation/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listin - Colaborative Shop Lists',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: MyColors.blue,
          scaffoldBackgroundColor: MyColors.green[50],
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: MyColors.blueAccent,
          ),
          listTileTheme: const ListTileThemeData(
            iconColor: MyColors.blueAccent,
          ),
          appBarTheme: const AppBarTheme(
            toolbarHeight: 72,
            backgroundColor: MyColors.blueAccent,
            centerTitle: true,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.normal,
            ),
          )),
      home: const ScreenRouter(),
    );
  }
}

class ScreenRouter extends StatelessWidget {
  const ScreenRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasData) {
            return HomeScreen(user: snapshot.data!,);
          }
          return const AuthScreen();
        }
      },
    );
  }
}
