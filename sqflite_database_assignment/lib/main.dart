import 'package:flutter/material.dart';
import 'package:sqflite_database_assignment/services/Db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stylish Database App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
        ),
      ),
      home: const MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  TextEditingController nameController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<Map<String, dynamic>> data = [];

  // Method to fetch all records from the database
  void fetchAllData() async {
    List<Map<String, dynamic>> dataList =
        await DbHelper.instance.querydatabase();
    setState(() {
      data = dataList;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Stylish Records'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nameController.clear();
          titleController.clear();
          descriptionController.clear();
          showRecordDialog(0);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: data.isEmpty
          ? Center(
              child: Text("No records found.",
                  style: TextStyle(color: Colors.grey[600])),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    title: Text(
                      data[index][DbHelper.dt_name],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Title: ${data[index][DbHelper.dt_title]}"),
                        Text("Description: ${data[index][DbHelper.dt_description]}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            nameController.text = data[index][DbHelper.dt_name];
                            titleController.text =
                                data[index][DbHelper.dt_title];
                            descriptionController.text =
                                data[index][DbHelper.dt_description];
                            showRecordDialog(data[index][DbHelper.dt_id]);
                          },
                          icon: const Icon(Icons.edit, color: Colors.orange),
                        ),
                        IconButton(
                          onPressed: () {
                            DbHelper.instance
                                .deleteRecord(data[index][DbHelper.dt_id]);
                            fetchAllData();
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void showRecordDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            id == 0 ? "Add Record" : "Update Record",
            style: const TextStyle(color: Colors.indigo),
          ),
          content: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Enter Name",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Enter Title",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter Description",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                String name = nameController.text.trim();
                String title = titleController.text.trim();
                String description = descriptionController.text.trim();
                if (name.isNotEmpty &&
                    title.isNotEmpty &&
                    description.isNotEmpty) {
                  if (id == 0) {
                    DbHelper.instance.InsertRecord({
                      DbHelper.dt_name: name,
                      DbHelper.dt_title: title,
                      DbHelper.dt_description: description,
                    });
                  } else {
                    DbHelper.instance.updateRecord({
                      DbHelper.dt_id: id,
                      DbHelper.dt_name: name,
                      DbHelper.dt_title: title,
                      DbHelper.dt_description: description,
                    });
                  }
                  fetchAllData();
                }
                nameController.clear();
                titleController.clear();
                descriptionController.clear();
                Navigator.of(context).pop();
              },
              child: Text(id == 0 ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }
}
