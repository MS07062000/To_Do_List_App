import 'dart:async';
import 'dart:convert';
// import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:location/location.dart';
import 'package:to_do_list_app/Database/note_model.dart';
import 'package:to_do_list_app/Helper/helper.dart';
import 'package:to_do_list_app/HomeScreen/note_content_page.dart';
import 'package:tuple/tuple.dart';

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(
    NotificationResponse details) async {
  if (details.payload == 'location_zone') {
    setNotified(details.id).then((isNotified) async {
      if (isNotified) {
        await FlutterLocalNotificationsPlugin().cancel(details.id ?? -1);
      }
    });
  }
}

class LocationNotificationHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String notificationChannelId = 'location_channel';
  String notificationChannelName = 'Location Notifications';
  String notificationChannelDescription =
      'Notifications for location-based notes';
  StreamSubscription<LocationData>? locationStreamSubscription;
  late BuildContext notificationContext;

  LocationNotificationHelper(BuildContext context) {
    notificationContext = context;
    initializeNotifications();
  }

  void initializeNotifications() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestPermission()
        .then((isPermissionGranted) async {
      if (isPermissionGranted!) {
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('launch_background');
        InitializationSettings initializationSettings =
            const InitializationSettings(
                android: initializationSettingsAndroid);
        await flutterLocalNotificationsPlugin
            .initialize(initializationSettings,
                onDidReceiveBackgroundNotificationResponse:
                    onDidReceiveBackgroundNotificationResponse,
                onDidReceiveNotificationResponse:
                    onDidReceiveNotificationResponse)
            .then((isInitialized) {
          if (isInitialized!) {
            // Future.delayed(const Duration(seconds: 5), startLocationMonitoring);
            startLocationMonitoring();
          }
        });
      }
    });
  }

  void onDidReceiveNotificationResponse(NotificationResponse details) async {
    if (details.payload != '') {
      setNotified(details.id).then((isNotified) async {
        NoteModel note = NoteModel.fromJson(json.decode(details.payload!));
        if (isNotified) {
          navigateToNoteView(notificationContext, note);
          await FlutterLocalNotificationsPlugin().cancel(details.id ?? -1);
        }
      });
    }
  }

  void navigateToNoteView(BuildContext context, NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteContentPage(note: note),
      ),
    );
  }

  void startLocationMonitoring() {
    // locationPermissionAndServicesEnabled().then((isEnabled) {
    //   log(isEnabled.toString());
    //   if (isEnabled) {
    //     locationStreamSubscription =
    //         Location().onLocationChanged.listen((LocationData location) async {
    //       log("Inside notification");
    //       log('${location.latitude},${location.longitude}');
    //       checkLocationZoneAndNotifyNotes(location);
    //       locationStreamSubscription?.pause(Future<void>(() async {
    //         log(DateTime.timestamp().toString());
    //         await Future.delayed(const Duration(seconds: 30),
    //             locationStreamSubscription?.resume);
    //       }));
    //     });
    //   }
    // });
    locationPermissionAndServicesEnabled().then((isPermissionEnabled) {
      // log(isPermissionEnabled);
      if (isPermissionEnabled) {
        Location().isBackgroundModeEnabled().then((value) async {
          // log(value.toString());
          if (!value) {
            Location().enableBackgroundMode().then((isEnabled) {
              if (isEnabled) {
                Location()
                    .changeSettings(interval: 30000)
                    .then((isSettingsChanged) {
                  if (isSettingsChanged) {
                    locationStreamSubscription = Location()
                        .onLocationChanged
                        .listen((LocationData location) async {
                      // log("Inside notification");
                      // log('${location.latitude},${location.longitude}');
                      checkLocationZoneAndNotifyNotes(location);
                    });
                  }
                });
              }
            });
          } else {
            Location()
                .changeSettings(interval: 30000)
                .then((isSettingsChanged) {
              if (isSettingsChanged) {
                locationStreamSubscription = Location()
                    .onLocationChanged
                    .listen((LocationData location) async {
                  // log("Inside notification");
                  // log('${location.latitude},${location.longitude}');
                  checkLocationZoneAndNotifyNotes(location);
                });
              }
            });
          }
        });
      }
    });
  }

  void stopLocationMonitoring() {
    locationStreamSubscription?.cancel();
  }

  void checkLocationZoneAndNotifyNotes(LocationData currentPosition) async {
    findNotesFromDestination(currentPosition, 50.00, true).then((value) {
      Tuple2<List<NoteModel>, bool> findNotesFromDestinationResult = value;
      if (findNotesFromDestinationResult.item2) {
        for (NoteModel note in findNotesFromDestinationResult.item1) {
          showNotification(note);
          setNotified(note.key);
        }
      }
    });
  }

  void showNotification(NoteModel note) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            notificationChannelId, notificationChannelName,
            channelDescription: notificationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            groupKey: DateTime.now().millisecondsSinceEpoch.toString(),
            vibrationPattern: Int64List.fromList(<int>[0, 2000]),
            styleInformation: BigTextStyleInformation(notificationBody(note)!,
                contentTitle: note.notetitle));

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // log(note.toJson().toString());
    await flutterLocalNotificationsPlugin.show(
      note.key,
      note.notetitle,
      notificationBody(note),
      platformChannelSpecifics,
      payload: json.encode(note.toJson()),
    );
  }

  String? notificationBody(NoteModel note) {
    if (note.textnote != null) {
      return note.textnote;
    }

    if (note.checklist!.isNotEmpty) {
      return note.checklist!.join("\n");
    }
    return null;
  }
}
