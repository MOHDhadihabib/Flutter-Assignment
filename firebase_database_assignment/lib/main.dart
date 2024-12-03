import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database_assignment/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase CRUD Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final user = auth.currentUser;

    Timer(
      Duration(seconds: 3),
      () {
        if (user != null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emaillogin = TextEditingController();
  TextEditingController passlogin = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emaillogin,
              decoration: InputDecoration(
                  hintText: "Email", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passlogin,
              decoration: InputDecoration(
                  hintText: "Password", border: OutlineInputBorder()),
              obscureText: true,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                String emailL = emaillogin.text.trim();
                String passL = passlogin.text.trim();

                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailL, password: passL);
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    print('No user found for that email.');
                  } else if (e.code == 'wrong-password') {
                    print('Wrong password provided for that user.');
                  }
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref("students");
  final key = FirebaseAuth.instance.currentUser!.uid;

  int id = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase CRUD"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by Title",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: databaseReference.child(key).onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var data = snapshot.data!.snapshot.value as Map;
                List<Widget> listItems = [];
                data.forEach((key, value) {
                  if (searchController.text.isEmpty ||
                      value['Title']
                          .toString()
                          .contains(searchController.text)) {
                    listItems.add(
                      Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        child: ListTile(
                          title: Text(value['Title']),
                          subtitle: Text(value['Description']),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              titleController.text = value['Title'];
                              descController.text = value['Description'];
                              emailController.text = value['Email'];
                              userNameController.text = value['Username'];
                              _showModal(int.parse(key));
                            },
                          ),
                        ),
                      ),
                    );
                  }
                });
                return ListView(children: listItems);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showModal(0);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showModal(int id) {
    titleController.clear();
    descController.clear();
    emailController.clear();
    userNameController.clear();
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              32, 32, 32, MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userNameController,
                decoration: InputDecoration(
                    hintText: "Username", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                    hintText: "Email", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                    hintText: "Title", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                    hintText: "Description", border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String title = titleController.text.trim();
                  String desc = descController.text.trim();
                  String email = emailController.text.trim();
                  String userName = userNameController.text.trim();

                  if (id == 0) {
                    id++;
                    databaseReference.child(key).child("$id").set({
                      "ID": id,
                      "Title": title,
                      "Description": desc,
                      "Email": email,
                      "Username": userName,
                      "DateOfPost": DateTime.now().toString(),
                    }).then(
                      (value) {
                        print("Successfully created");
                      },
                    ).onError(
                      (error, stackTrace) {
                        print("Failed task");
                      },
                    );
                  } else {
                    databaseReference.child(key).child("$id").update({
                      "ID": id,
                      "Title": title,
                      "Description": desc,
                      "Email": email,
                      "Username": userName,
                      "DateOfPost": DateTime.now().toString(),
                    }).then(
                      (value) {
                        print("Successfully updated");
                      },
                    ).onError(
                      (error, stackTrace) {
                        print("Failed task");
                      },
                    );
                  }
                  Navigator.pop(context);
                },
                child: id == 0 ? Text("Add") : Text("Update"),
              ),
            ],
          ),
        );
      },
    );
  }
}
