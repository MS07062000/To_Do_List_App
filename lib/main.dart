import 'package:flutter/material.dart';
import 'package:to_do_list_app/LocationNotesScreen/get_current_location.dart';
import 'package:to_do_list_app/Main/home_page.dart';
import 'package:to_do_list_app/Notifications/background_notification.dart';

Future main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    getCurrentLocation(context);
    BackgroundNotification();
  }

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
