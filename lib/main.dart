// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/add_new_note_view.dart';
import 'package:to_do_list_app/home_View.dart';
import 'package:to_do_list_app/trash_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home': (context) => MyHomePage(),
        '/addNewNote': (context) => AddNewNoteView(),
        // '/trash' : (context)=>
      },
      title: 'Note App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
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
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _screens = [
    HomeView(),
    AddNewNoteView(),
    TrashView(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BottomNavBarProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Note App'),
        ),
        body: Consumer<BottomNavBarProvider>(
          builder: (context, bottomNavBarProvider, child) {
            return _screens[bottomNavBarProvider.currentIndex];
          },
        ),
        bottomNavigationBar: Consumer<BottomNavBarProvider>(
          builder: (context, bottomNavBarProvider, child) {
            return BottomNavigationBar(
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
}
