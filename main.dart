import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'database_helper.dart'; // Import database helper

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StudentMarksScreen(),
    );
  }
}

class StudentMarksScreen extends StatefulWidget {
  @override
  _StudentMarksScreenState createState() => _StudentMarksScreenState();
}

class _StudentMarksScreenState extends State<StudentMarksScreen> {
  final _nameController = TextEditingController();
  final _marksController = TextEditingController();
  List<Pokemon> _pokemonList = [];
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    fetchPokemonCards();
    _loadStudents();
  }

  // Fetch Pokémon cards from the API
  Future<void> fetchPokemonCards() async {
    final response = await http.get(Uri.parse('https://api.pokemontcg.io/v2/cards'));
    
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        _pokemonList = (data['data'] as List).map((item) => Pokemon.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load Pokemon');
    }
  }

  // Load students from the database
  Future<void> _loadStudents() async {
    final students = await DatabaseHelper().getStudents();
    setState(() {
      _students = students;
    });
  }

  // Add a new student to the database
  Future<void> _addStudent() async {
    if (_nameController.text.isEmpty || _marksController.text.isEmpty) {
      return;
    }
    final student = {
      'name': _nameController.text,
      'marks': int.parse(_marksController.text),
    };
    await DatabaseHelper().insertStudent(student);
    _loadStudents(); // Reload the student list
    _nameController.clear();
    _marksController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Marks & Pokémon')),
      body: Column(
        children: [
          // Pokémon cards display
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: _pokemonList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: _pokemonList[index].imageUrl,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  title: Text(_pokemonList[index].name),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Image.network(_pokemonList[index].imageUrl),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Student marks management
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Student Name'),
                ),
                TextField(
                  controller: _marksController,
                  decoration: InputDecoration(labelText: 'Marks'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addStudent,
                  child: Text('Add Student'),
                ),
                SizedBox(height: 10),
                Text('Student Marks:', style: TextStyle(fontSize: 18)),
                // DataTable to display students
                Expanded(
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Marks')),
                    ],
                    rows: _students.map((student) {
                      return DataRow(cells: [
                        DataCell(Text(student['name'])),
                        DataCell(Text(student['marks'].toString())),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Pokemon {
  final String name;
  final String imageUrl;

  Pokemon({required this.name, required this.imageUrl});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      imageUrl: json['images']['large'],
    );
  }
}
