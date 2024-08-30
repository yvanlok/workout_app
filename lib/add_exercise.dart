import 'package:flutter/material.dart';
import "exercises.dart";

class AddExercise extends StatelessWidget {
  const AddExercise({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Exercise'),
      ),
      body: Form(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SearchBox(),
            TextFormField(
              decoration: InputDecoration(labelText: 'Reps'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Weight'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Sets'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add the exercise to the database
              },
              child: Text('Add Exercise'),
            ),
          ],
        ),
      )),
    );
  }
}

class SearchBox extends StatefulWidget {
  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      // Handle search logic here
      print("Search query: ${_searchController.text}");
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Search',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }
}
