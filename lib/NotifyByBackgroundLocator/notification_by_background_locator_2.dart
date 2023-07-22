// import 'dart:isolate';
// import 'dart:ui';

// import 'package:background_locator_2/background_locator.dart';
// import 'package:background_locator_2/location_dto.dart';
// import 'package:background_locator_2/settings/android_settings.dart'
//     as bgl_android_settings;
// import 'package:background_locator_2/settings/locator_settings.dart'
//     as bgl_locator_settings;
// import 'package:geolocator/geolocator.dart';
// import 'package:to_do_list_app/Helper/location_handler.dart';
// import 'package:to_do_list_app/NotifyByBackgroundLocator/notes_notification_by_locator.dart';

// class BackgroundLocationFetch {
//   static const String _isolateName = "LocatorIsolate";
//   ReceivePort port = ReceivePort();
//   BackgroundLocationFetch() {
//     initState();
//   }
//   void initState() async {
//     if (await locationPermissionAndServicesEnabled()) {
//       IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);
//       port.listen((dynamic data) {
//         LocationDto? locationDto =
//             (data != null) ? LocationDto.fromJson(data) : null;
//         LocationNotificationHelperByBackgroundLocator(Position(
//             longitude: locationDto!.longitude,
//             latitude: locationDto.latitude,
//             timestamp: DateTime.now(),
//             accuracy: locationDto.accuracy,
//             altitude: locationDto.altitude,
//             heading: locationDto.heading,
//             speed: locationDto.speed,
//             speedAccuracy: locationDto.speedAccuracy));
//       });
//       await initPlatformState();
//       await startLocator();
//     }
//   }

//   Future<void> initPlatformState() async {
//     await BackgroundLocator.initialize();
//   }

//   @pragma('vm:entry-point')
//   static void callback(LocationDto location) async {
//     final SendPort? send = IsolateNameServer.lookupPortByName(_isolateName);
//     send?.send(location.toJson());
//   }

//   Future<void> startLocator() async {
//     Map<String, dynamic> data = {'countInit': 1};
//     return await BackgroundLocator.registerLocationUpdate(
//       callback,
//       initDataCallback: data,
//       autoStop: false,
//       androidSettings: const bgl_android_settings.AndroidSettings(
//         accuracy: bgl_locator_settings.LocationAccuracy.NAVIGATION,
//         interval: 30,
//         distanceFilter: 0,
//         client: bgl_android_settings.LocationClient.google,
//         androidNotificationSettings:
//             bgl_android_settings.AndroidNotificationSettings(
//           notificationChannelName: 'Location tracking',
//           notificationTitle: 'Start Location Tracking',
//           notificationMsg: 'Track location in background',
//           notificationBigMsg:
//               'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
//         ),
//       ),
//     );
//   }
// }
