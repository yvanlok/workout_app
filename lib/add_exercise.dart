import 'package:flutter/material.dart';
import 'search_page.dart';
import 'exercises.dart';

class AddExercise extends StatefulWidget {
  const AddExercise({super.key});

  @override
  _AddExerciseState createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to manage the input fields
  final TextEditingController _exerciseController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();

  void _openSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: SearchPage<Map<String, dynamic>>(
        items: exercises,
        searchLabel: 'Search exercises by name',
        suggestion: Center(
          child: Text('Filter exercises by name'),
        ),
        failure: Center(
          child: Text('No exercise found :('),
        ),
        filter: (exercise) => [exercise['name']],
        builder: (exercise) => ListTile(
          leading: exercise['images'] != null && exercise['images'].isNotEmpty
              ? Image.asset(
                  'assets/exercise_images/${exercise['id']}_1.jpg',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print("Error: $error");
                    return Icon(Icons.image_not_supported, size: 50);
                  },
                )
              : Icon(Icons.image_not_supported, size: 50),
          title: Text(exercise['name']),
          subtitle: Text(
            '${exercise['category']} - '
            '${exercise['level']} - '
            '${exercise['force'] ?? 'Unknown force'}',
          ),
          trailing: Text(exercise['equipment'] ?? 'No equipment'),
          onTap: () {
            setState(() {
              _exerciseController.text = exercise['name'];
            });
            Navigator.pop(context); // Close the search dialog
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Exercise'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _exerciseController,
                  decoration: InputDecoration(
                    labelText: 'Exercise Name',
                    suffixIcon: Icon(Icons.search),
                  ),
                  readOnly: true, // Make this field read-only
                  onTap: () => _openSearch(context), // Open search on tap
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _repsController,
                  decoration: InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                  validator: _validateInteger,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                    suffixText: 'kg',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateWeight,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _setsController,
                  decoration: InputDecoration(labelText: 'Sets'),
                  keyboardType: TextInputType.number,
                  validator: _validateInteger,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Add the exercise to the database
                    if (_formKey.currentState!.validate()) {
                      // Perform the add operation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Exercise added successfully!')),
                      );
                      // Clear the fields
                      _exerciseController.clear();
                      _repsController.clear();
                      _weightController.clear();
                      _setsController.clear();
                    }
                  },
                  child: Text('Add Exercise'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateInteger(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final int? intValue = int.tryParse(value);
    if (intValue == null) {
      return 'Please enter a valid integer';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final double? doubleValue = double.tryParse(value);
    if (doubleValue == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}
