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
          child: RealTimeWidget(),
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

    var db = FirebaseFirestore.instance;
    // we are going to check on the user status in real time 
    // design patterns 
    // singleton
    // https://en.wikipedia.org/wiki/Singleton_pattern
    FirebaseAuth.instance.authStateChanges().listen((User? user) {

      if(user != null){
        print("USER: ${user.uid}");
      } else {
        print("SIGNED OUT");
      }
    });

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
          onPressed: () async {
            try {
              // we use try to fail gracefully
              // https://en.wikipedia.org/wiki/Graceful_exit
              final user = 
                await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                  email: login.text, 
                  password: password.text
                );
              print("USER CREATED: ${user.user?.uid}");

            } on FirebaseException catch(e) {
              if(e.code == 'weak-password') {
                print("your password is weak and so are you.");
              } else if (e.code == 'email-already-in-use') {
                print("account exists");
              }
            } catch(e) {
              print(e);
            } finally {
              // this code will always run
              // normally used to do clean up
            }
          }, 
          child: const Text("Sign up")
        ),
        TextButton(
          child: const Text("Log in"),
          onPressed: () async {
            try {
              final user = 
                await  FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: login.text, 
                  password: password.text
                );
            } catch (e) {
              print(e);
            }
          }
        ),
        TextButton(
          child: const Text("Log out"),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          }
        ),
        TextButton( 
          child: const Text("Add record"),
          onPressed: () {
            final puppy = <String, dynamic> {
              "name" : "Fido",
              "breed" : "Pomeranian",
              "age" : 10.0
            };

            FirebaseFirestore.instance.collection("perritos").add(puppy).then(
              (DocumentReference document) => print("new document created: ${document.id}")
            );
          }
        ),
        TextButton( 
          child: const Text("Query"),
          onPressed: () {
            db.collection("perritos").get().then(
              (perritos) {
                for(var currentDoc in perritos.docs) {
                  print("DOCUMENT: ${currentDoc.data()}");
                }
              }
            );
          }
        ),
      ],
    );
  }
}

class RealTimeWidget extends StatefulWidget {
  const RealTimeWidget({super.key});

  @override
  State<RealTimeWidget> createState() => _RealTimeWidgetState();
}

class _RealTimeWidgetState extends State<RealTimeWidget> {

  final Stream<QuerySnapshot> puppiesStream = 
    FirebaseFirestore.instance.collection("perritos").snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: puppiesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(snapshot.hasError){
          return const Text("ERROR ON QUERY, PLEASE VERIFY");
        }

        if(snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return ListView(
          children: snapshot.data!.docs
            .map((DocumentSnapshot doc) {
              // iterate through docs and build a widget for each one 

              // step 1
              // get data of current doc 
              Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

              // with data now available step 2 - build a widget
              return ListTile(
                title: Text(data['name']),
                subtitle: Text(data['breed']),
              );
            }).toList().cast(),
        );
      }
    );
  }
}