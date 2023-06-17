import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/AddNoteScreen/add_new_note_view.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/HomeScreen/home_view.dart';
import 'package:to_do_list_app/LocationNotesScreen/location_view.dart';
import 'package:to_do_list_app/Notifications/notes_notification.dart';
import 'package:to_do_list_app/TrashScreen/trash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  List<dynamic> _notesKeys = [];
  int get currentIndex => _currentIndex;
  List<dynamic> get noteKeys => _notesKeys;
  ValueNotifier<bool> refreshNotifier = ValueNotifier<bool>(false);

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setNotesKeys(List<dynamic> noteKeys) {
    _notesKeys = noteKeys;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late LocationNotificationHelper notificationHelper =
      LocationNotificationHelper();
  final List<Widget> _screens = [
    const HomeView(),
    const LocationView(),
    const AddNewNoteView(),
    const TrashView()
  ];

  @override
  void initState() {
    super.initState();
    notificationHelper.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BottomNavBarProvider(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Note App'),
          actions: [
            Consumer<BottomNavBarProvider>(
              builder: (context, bottomNavBarProvider, child) {
                if (bottomNavBarProvider.currentIndex == 0) {
                  return IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      if (bottomNavBarProvider.noteKeys.isNotEmpty) {
                        deleteSelectedNotes(context, bottomNavBarProvider);
                      }
                    },
                  );
                } else if (bottomNavBarProvider.currentIndex == 1) {
                  return IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      if (bottomNavBarProvider.noteKeys.isNotEmpty) {
                        deleteSelectedNotes(context, bottomNavBarProvider);
                      }
                    },
                  );
                } else if (bottomNavBarProvider.currentIndex == 3) {
                  return IconButton(
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () {
                      deletePermanentlyTheDeletedNotes(
                          context, bottomNavBarProvider);
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
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
                  icon: Icon(Icons.assignment),
                  label: 'Notes',
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
                  icon: Icon(Icons.delete_outlined),
                  label: 'Trash',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void deleteSelectedNotes(
      BuildContext context, BottomNavBarProvider bottomNavBarProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(
            "Do you want to delete all selected notes?",
          ),
          actions: <Widget>[
            TextButton(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                setDeleteOfAllSelectedNote(bottomNavBarProvider.noteKeys)
                    .then((value) {
                  bottomNavBarProvider.refreshNotifier.value = true;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void deletePermanentlyTheDeletedNotes(
      BuildContext context, BottomNavBarProvider bottomNavBarProvider) {
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
              onPressed: () {
                // final navigator = Navigator.of(context);
                deleteAllPermanently(bottomNavBarProvider.noteKeys)
                    .then((value) {
                  bottomNavBarProvider.refreshNotifier.value = true;
                  Navigator.of(context).pop();
                });
                // navigator.pop();
              },
            ),
          ],
        );
      },
    );
  }
}
