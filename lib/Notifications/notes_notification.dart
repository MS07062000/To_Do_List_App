import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions()
          .then((isPermissionGranted) async {
        if (isPermissionGranted!) {
          final DarwinInitializationSettings initializationSettingsDarwin =
              DarwinInitializationSettings(onDidReceiveLocalNotification:
                  (int id, String? title, String? body, String? payload) {
            onDidReceiveIOSNotificationResponse(id, payload!);
          });

          InitializationSettings initializationSettings =
              InitializationSettings(iOS: initializationSettingsDarwin);
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

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestPermission()
          .then((isPermissionGranted) async {
        if (isPermissionGranted!) {
          const AndroidInitializationSettings initializationSettingsAndroid =
              AndroidInitializationSettings('launch_background');
          final DarwinInitializationSettings initializationSettingsDarwin =
              DarwinInitializationSettings(onDidReceiveLocalNotification:
                  (int id, String? title, String? body, String? payload) {
            onDidReceiveIOSNotificationResponse(id, payload!);
          });

          InitializationSettings initializationSettings =
              InitializationSettings(
                  android: initializationSettingsAndroid,
                  iOS: initializationSettingsDarwin);
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

  void onDidReceiveIOSNotificationResponse(int id, String payload) async {
    if (payload != '') {
      setNotified(id).then((isNotified) async {
        NoteModel note = NoteModel.fromJson(json.decode(payload));
        if (isNotified) {
          navigateToNoteView(notificationContext, note);
          await FlutterLocalNotificationsPlugin().cancel(id);
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
    findNotesFromDestination(currentPosition, 10.00, true).then((value) {
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

    DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true, // to show alert
      presentBadge: false, // to update the app's badge count
      presentSound: false, // to play a sound
      threadIdentifier: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // to group notifications
      interruptionLevel: InterruptionLevel.critical,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics);

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
    if (note.textnote != null && note.textnote!.isNotEmpty) {
      return note.textnote;
    }

    if (note.checklist != null && note.checklist!.isNotEmpty) {
      return note.checklist!.join("\n");
    }
    return null;
  }
}
