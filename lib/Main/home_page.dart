import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/AddNoteScreen/add_new_note_view.dart';
import 'package:to_do_list_app/HomeScreen/home_view.dart';
import 'package:to_do_list_app/LocationNotesScreen/location_view.dart';
import 'package:to_do_list_app/Main/bottom_navbar_provider.dart';
import 'package:to_do_list_app/Notifications/notes_notification.dart';
import 'package:to_do_list_app/TrashScreen/trash_view.dart';

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
    // insertFakeData();
    // notificationHelper.initializeApp();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BottomNavBarProvider(),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Note App'),
          actions: [
            Consumer<BottomNavBarProvider>(
              builder: (context, bottomNavBarProvider, child) {
                if (bottomNavBarProvider.isNotesAvailable.value &&
                    (bottomNavBarProvider.currentIndex.value == 0 ||
                        bottomNavBarProvider.currentIndex.value == 1)) {
                  return Row(
                    children: [
                      PopupMenuButton(
                        icon: const Icon(Icons.sort),
                        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                          const PopupMenuItem(
                            value: 'noteTitle',
                            child: Text('Sort by Note Title'),
                          ),
                          if (bottomNavBarProvider
                              .isLocationServicesAvailable.value) ...[
                            const PopupMenuItem(
                              value: 'location',
                              child: Text('Sort by Location'),
                            ),
                          ],
                        ],
                        onSelected: (selectedOption) {
                          bottomNavBarProvider.sortBy.value = selectedOption;
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          if (bottomNavBarProvider.noteKeys.isNotEmpty) {
                            // deleteSelectedNotes(context, bottomNavBarProvider);
                          }
                        },
                      ),
                    ],
                  );
                } else if (bottomNavBarProvider.isNotesAvailable.value &&
                    bottomNavBarProvider.currentIndex.value == 3) {
                  return IconButton(
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () {
                      // deletePermanentlyTheDeletedNotes(
                      //     context, bottomNavBarProvider);
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable:
              Provider.of<BottomNavBarProvider>(context, listen: false)
                  .currentIndex,
          builder: (context, currentIndex, child) {
            return _screens[currentIndex];
          },
        ),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable:
              Provider.of<BottomNavBarProvider>(context, listen: false)
                  .currentIndex,
          builder: (context, currentIndex, child) {
            return BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              onTap: (index) {
                Provider.of<BottomNavBarProvider>(context, listen: false)
                    .currentIndex
                    .value = index;
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

  // void deleteSelectedNotes(
  //     BuildContext context, BottomNavBarProvider bottomNavBarProvider) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: const Text(
  //           "Do you want to delete all selected notes?",
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //               child: const Text("No"),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               }),
  //           TextButton(
  //             child: const Text("Yes"),
  //             onPressed: () {
  //               setDeleteOfAllSelectedNote(bottomNavBarProvider.noteKeys)
  //                   .then((value) {
  //                 bottomNavBarProvider.refreshNotifier.value = true;
  //                 Navigator.of(context).pop();
  //               });
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void deletePermanentlyTheDeletedNotes(
  //   BuildContext context,
  //   BottomNavBarProvider bottomNavBarProvider,
  // ) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: const Text(
  //           "Do you want to delete all notes permanently?",
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text("No"),
  //             onPressed: () => Navigator.of(context).pop(),
  //           ),
  //           TextButton(
  //             child: const Text("Yes"),
  //             onPressed: () {
  //               // final navigator = Navigator.of(context);
  //               deleteAllPermanently(bottomNavBarProvider.noteKeys)
  //                   .then((value) {
  //                 bottomNavBarProvider.refreshNotifier.value = true;
  //                 Navigator.of(context).pop();
  //               });
  //               // navigator.pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}