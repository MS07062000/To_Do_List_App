import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/AddNoteScreen/add_new_note.dart';
import 'package:to_do_list_app/Helper/connectivity_handler.dart';
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
  final List<Widget> _screens = [
    const HomeView(),
    const LocationView(),
    const AddNewNoteView(),
    const TrashView()
  ];

  ConnectivityCheck connectivityCheck = ConnectivityCheck();
  late LocationNotificationHelper locationNotificationHelper;

  @override
  void initState() {
    locationNotificationHelper = LocationNotificationHelper(context);
    super.initState();
    connectivityCheck.startStreamSubscription(context);
  }

  @override
  void dispose() {
    locationNotificationHelper.stopLocationMonitoring();
    connectivityCheck.stopStreamSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BottomNavBarProvider>(
      create: (_) => BottomNavBarProvider(),
      builder: (context, child) => Scaffold(
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
                  label: 'Location List',
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
}
