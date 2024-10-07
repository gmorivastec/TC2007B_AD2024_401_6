import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


// install firebase cli
// firebase login
// dart pub global activate flutterfire_cli
// add pub installation folder to PATH if needed
// add libraries (pubspec or cli)
// flutter pub add firebase_core
// flutter pub add firebase_auth
// flutter pub add cloud_firestore
// flutterfire configure

Future<void> main() async {

  // since it's async now we need to ensure native bindings are up
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: LoginWidget(),
        ),
      ),
    );
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {

  // lets add some states!
  TextEditingController login = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    login.text = "";
    password.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Login'
            ),
            controller: login,
          )
        ),
        Container(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password'
            ),
            controller: password,
            obscureText: true,
          )
        ),
        TextButton(
          onPressed: () {}, 
          child: const Text("Sign up")
        ),
        TextButton(
          onPressed: () {}, 
          child: const Text("Log in")
        ),
        TextButton(
          onPressed: () {}, 
          child: const Text("Log out")
        ),
        TextButton(
          onPressed: () {}, 
          child: const Text("Add record")
        ),
        TextButton(
          onPressed: () {}, 
          child: const Text("Query")
        ),
      ],
    );
  }
}