
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

  TextEditingController searchController = TextEditingController();

  DateTime? selectedDate;

  List<Map<String, dynamic>> showAll = [];

  List<Map<String, dynamic>> filteredData = [];

  var taskBox = Hive.box("taskBox");

  createData(Map<String, dynamic> row) async {

    await taskBox.add(row);

    readAll();

  }

  updateData(int? key, Map<String, dynamic> row) async {

    await taskBox.put(key, row);

    readAll();

  }

  readAll() async {

    var data = taskBox.keys.map((e) {

      final items = taskBox.get(e);

      return {

        "key": e,

        "name": items["name"],

        "email": items["email"],

        "title": items["title"],

        "desc": items["desc"],

        "date": items["date"],

      };

    }).toList();

    setState(() {

      showAll = data.reversed.toList();

      filteredData = showAll;

    });

  }

  filterData(String query) {

    setState(() {

      filteredData = showAll

          .where((element) =>

              element["name"].toString().toLowerCase().contains(query.toLowerCase()) ||

              element["email"].toString().toLowerCase().contains(query.toLowerCase()) ||

              element["title"].toString().toLowerCase().contains(query.toLowerCase()) ||

              element["desc"].toString().toLowerCase().contains(query.toLowerCase()))

          .toList();

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

      appBar: AppBar(

        title: TextField(

          controller: searchController,

          decoration: const InputDecoration(hintText: "Search"),

          onChanged: filterData,

        ),

      ),

      floatingActionButton: FloatingActionButton(

        onPressed: () {

          meraModal(0);

        },

        child: const Icon(Icons.add),

      ),

      body: ListView.builder(

        itemCount: filteredData.length,

        itemBuilder: (context, index) {

          return ListTile(

            title: Text(filteredData[index]["title"] ?? ''),

            subtitle: Text(

                "${filteredData[index]["name"]}, ${filteredData[index]["email"]}\n${filteredData[index]["desc"] ?? ''}\nDate: ${filteredData[index]["date"] ?? ''}"),

            trailing: Row(

              mainAxisSize: MainAxisSize.min,

              children: [

                IconButton(

                  onPressed: () {

                    var updateValue = filteredData[index]["key"];

                    meraModal(updateValue);

                  },

                  icon: const Icon(Icons.edit),

                ),

                IconButton(

                  onPressed: () {

                    var deleteValue = filteredData[index]["key"];

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

  void meraModal(int id) {

    nameController.clear();

    emailController.clear();

    titleController.clear();

    descController.clear();

    selectedDate = null;

    if (id != 0) {

      final item = showAll.firstWhere(

        (element) => element["key"] == id,

      );

      nameController.text = item["name"];

      emailController.text = item["email"];

      titleController.text = item["title"];

      descController.text = item["desc"];

      selectedDate = DateTime.parse(item["date"]);

    }

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

              TextField(

                controller: nameController,

                decoration: const InputDecoration(hintText: "Enter Your Name"),

              ),

              TextField(

                controller: emailController,

                decoration: const InputDecoration(hintText: "Enter Your Email"),

              ),

              TextField(

                controller: titleController,

                decoration: const InputDecoration(hintText: "Enter Your Title"),

              ),

              TextField(

                controller: descController,

                decoration: const InputDecoration(hintText: "Enter Your Description"),

              ),

              const SizedBox(height: 10),

              ElevatedButton(

                onPressed: () async {

                  selectedDate = await showDatePicker(

                    context: context,

                    initialDate: DateTime.now(),

                    firstDate: DateTime(2000),

                    lastDate: DateTime(2100),

                  );

                },

                child: Text(selectedDate == null

                    ? "Select Date"

                    : selectedDate!.toLocal().toString().split(' ')[0]),

              ),

              const SizedBox(height: 10),

              ElevatedButton(

                onPressed: () {

                  String name = nameController.text.toString();

                  String email = emailController.text.toString();

                  String title = titleController.text.toString();

                  String desc = descController.text.toString();

                  if (name.isEmpty || email.isEmpty || title.isEmpty || desc.isEmpty || selectedDate == null) {

                    ScaffoldMessenger.of(context).showSnackBar(

                      const SnackBar(content: Text("All fields must be filled out")),

                    );

                    return;

                  }

                  var data = {

                    "name": name,

                    "email": email,

                    "title": title,

                    "desc": desc,

                    "date": selectedDate!.toIso8601String(),

                  };

                  if (id == 0) {

                    createData(data);

                  } else {

                    updateData(id, data);

                  }

                  Navigator.pop(context);

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