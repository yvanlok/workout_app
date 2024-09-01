import 'package:flutter/material.dart';
import "add_exercise.dart";
import "navigation_bar.dart";
import "exercises.dart";
import 'package:path_provider/path_provider.dart';
import "package:hive/hive.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();

  // Initialize Hive with the application documents directory
  Hive.init(dir.path);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Future<List<Map<String, dynamic>>>? _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = Future.value(exercises); // Load exercises
    print("Exercises: $exercises");
  }

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Example pages
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.blue, // Set the background color to blue
      ),
      body: const Center(
        child: Text('Home Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the new page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExercise()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Search Page'),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Page'),
    );
  }
}
