import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/AddNoteScreen/add_new_note_view.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/HomeScreen/home_view.dart';
import 'package:to_do_list_app/LocationNotesScreen/location_view.dart';
import 'package:to_do_list_app/TrashScreen/trash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class BottomNavBarProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _screens = [
    const HomeView(),
    const LocationView(),
    const AddNewNoteView(),
    const TrashView()
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BottomNavBarProvider(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Note App'),
          actions: BottomNavBarProvider().currentIndex == 3
              ? [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deletePermanentlyTheDeletedNotes(context);
                    },
                  ),
                ]
              : null,
        ),
        body: Consumer<BottomNavBarProvider>(
          builder: (context, bottomNavBarProvider, child) {
            return _screens[bottomNavBarProvider.currentIndex];
          },
        ),
        bottomNavigationBar: Consumer<BottomNavBarProvider>(
          builder: (context, bottomNavBarProvider, child) {
            return BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: bottomNavBarProvider.currentIndex,
              onTap: (index) {
                bottomNavBarProvider.setCurrentIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_on),
                  label: 'Location Notes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Add Note',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.delete),
                  label: 'Trash',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void deletePermanentlyTheDeletedNotes(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            "Do you want to delete all notes permanently?",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                final navigator = Navigator.of(context);
                await deleteAllPermanently();
                navigator.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
