// import 'dart:async';
// import 'dart:developer';
// import 'package:connectivity_plus/connectivity_plus.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:to_do_list_app/Database/note_model.dart';
// import 'package:to_do_list_app/LocationNotesScreen/get_current_location.dart';
// import 'package:to_do_list_app/Notifications/notes_notification.dart';
// import 'package:workmanager/workmanager.dart';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     log("inside task");
//     if (task == "backgroundWorkManager") {
//       var connectivityResult = await (Connectivity().checkConnectivity());
//       bool locationServices = await locationPermissionAndServicesEnabled();
//       if (connectivityResult == ConnectivityResult.mobile ||
//           connectivityResult == ConnectivityResult.wifi && locationServices) {
//         log("inside backgroundWorkManager");
//         LocationNotificationHelper();
//         // Timer.periodic(const Duration(minutes: 2), (timer) {
//         //   log("inside timer");
//         //   LocationNotificationHelper();
//         // });
//       }
//     }
//     return Future.value(true);
//   });
// }

// class BackgroundWorkManager {
//   Future<void> initializeWorkManager() async {
//     log("inside initialize");
//     await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
//   }

//   Future<void> registerTask() async {
//     log("inside register");
//     await Workmanager().registerPeriodicTask("1", "backgroundWorkManager",
//         constraints: Constraints(networkType: NetworkType.connected),
//         existingWorkPolicy: ExistingWorkPolicy.replace);
//     // await Workmanager().registerOneOffTask("1", "backgroundWorkManager",
//     //     existingWorkPolicy: ExistingWorkPolicy.replace);
//   }

//   BackgroundWorkManager() {
//     workManagerProcess();
//   }

//   void workManagerProcess() async {
//     await initializeWorkManager();
//     await registerTask();
//   }
// }
