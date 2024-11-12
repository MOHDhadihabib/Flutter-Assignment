import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("taskBox");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  List<Map<String, dynamic>> showAll = [];

  var taskBox = Hive.box("taskBox");

  // Create data
  createData(Map<String, dynamic> row) async {
    await taskBox.add(row);
    readAll();
  }

  // Update data
  updateData(int? key, Map<String, dynamic> row) async {
    await taskBox.put(key, row);
    readAll();
  }

  // Read all tasks
  readAll() async {
    var data = taskBox.keys.map((e) {
      final items = taskBox.get(e);
      return {
        "key": e,
        "name": items["name"],
        "email": items["email"],
        "title": items["title"],
        "desc": items["desc"],
      };
    }).toList();

    setState(() {
      showAll = data.reversed.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    readAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          meraModal(0);
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: showAll.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(showAll[index]["title"] ?? ''),
            subtitle: Text(
                "${showAll[index]["name"]}, ${showAll[index]["email"]}\n${showAll[index]["desc"] ?? ''}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    var updateValue = showAll[index]["key"];
                    meraModal(updateValue);
                  },
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    var deleteValue = showAll[index]["key"];
                    taskBox.delete(deleteValue);
                    readAll();
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Function to show the modal and handle both add and edit functionality
  void meraModal(int id) {
    // Clear the text fields when opening the modal
    nameController.clear();
    emailController.clear();
    titleController.clear();
    descController.clear();

    // If id != 0, this means we are editing, so load the current values into the controllers
    if (id != 0) {
      final item = showAll.firstWhere(
        (element) => element["key"] == id,
      );
      nameController.text = item["name"];
      emailController.text = item["email"];
      titleController.text = item["title"];
      descController.text = item["desc"];
    }

    // Show the modal
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            32,
            32,
            32,
            MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name field
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: "Enter Your Name"),
              ),
              // Email field
              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: "Enter Your Email"),
              ),
              // Title field
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: "Enter Your Title"),
              ),
              // Description field
              TextField(
                controller: descController,
                decoration: const InputDecoration(hintText: "Enter Your Description"),
              ),
              const SizedBox(height: 10),
              // Add/Update button
              ElevatedButton(
                onPressed: () {
                  String name = nameController.text.toString();
                  String email = emailController.text.toString();
                  String title = titleController.text.toString();
                  String desc = descController.text.toString();

                  // Check for empty fields
                  if (name.isEmpty || email.isEmpty || title.isEmpty || desc.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("All fields must be filled out")),
                    );
                    return;
                  }

                  // Prepare the data
                  var data = {
                    "name": name,
                    "email": email,
                    "title": title,
                    "desc": desc
                  };

                  if (id == 0) {
                    // Add new task
                    createData(data);
                  } else {
                    // Update existing task
                    updateData(id, data);
                  }
                  Navigator.pop(context); // Close the modal
                },
                child: id == 0 ? const Text("Add") : const Text("Update"),
              ),
            ],
          ),
        );
      },
    );
  }
}
