// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:to_do_list_app/Main/bottom_navbar_provider.dart';

// class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
//   const MyAppBar({super.key});
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);

//   @override
//   State<MyAppBar> createState() => _MyAppBarState();
// }

// class _MyAppBarState extends State<MyAppBar> {
//   int currentIndex = 0;
//   bool isNotesAvailable = false;
//   bool isLocationAvailable = false;
//   @override
//   void initState() {
//     super.initState();
//     // Provider.of<BottomNavBarProvider>(context, listen: false)
//     //     .actionStateValue
//     //     .addListener(refreshState);
//   }

//   @override
//   void dispose() {
//     // Provider.of<BottomNavBarProvider>(context, listen: false)
//     //     .actionStateValue
//     //     .removeListener(refreshState);
//     super.dispose();
//   }

//   // void refreshState() {
//   //   if (mounted) {
//   //     setState(() {
//   //       print("Inside SetState");
//   //       currentIndex = Provider.of<BottomNavBarProvider>(context, listen: false)
//   //           .actionStateValue
//   //           .value
//   //           .currentIndex;
//   //       isNotesAvailable =
//   //           Provider.of<BottomNavBarProvider>(context, listen: false)
//   //               .actionStateValue
//   //               .value
//   //               .isNotesAvailable;
//   //       isLocationAvailable =
//   //           Provider.of<BottomNavBarProvider>(context, listen: false)
//   //               .actionStateValue
//   //               .value
//   //               .isLocationServicesAvailable;
//   //     });
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//         valueListenable:
//             Provider.of<BottomNavBarProvider>(context).currentIndex,
//         builder: (context, currentIndex, child) {
//           return AppBar(
//             automaticallyImplyLeading: false,
//             title: const Text('Note App'),
//             actions: <Widget>[
//               ValueListenableBuilder(
//                   valueListenable:
//                       Provider.of<BottomNavBarProvider>(context, listen: false)
//                           .isNotesAvailable,
//                   builder: (context, isNotesAvailable, child) {
//                     if (isNotesAvailable &&
//                         (currentIndex == 0 || currentIndex == 1)) {
//                       // if (actionStateValue == 0 || actionStateValue == 1) {
//                       return Row(
//                         children: [
//                           PopupMenuButton(
//                             icon: const Icon(Icons.sort),
//                             itemBuilder: (BuildContext context) =>
//                                 <PopupMenuEntry>[
//                               const PopupMenuItem(
//                                 value: 'noteTitle',
//                                 child: Text('Sort by Note Title'),
//                               ),
//                               const PopupMenuItem(
//                                 value: 'location',
//                                 child: Text('Sort by Location'),
//                               )
//                             ],
//                             onSelected: (selectedOption) {
//                               // bottomNavBarProvider.sortBy.value =
//                               //     selectedOption;
//                             },
//                           ),
//                           const SizedBox(width: 8),
//                           IconButton(
//                             icon: const Icon(Icons.delete),
//                             onPressed: () {
//                               // if (bottomNavBarProvider.noteKeys.isNotEmpty) {
//                               //   deleteSelectedNotes(context, bottomNavBarProvider);
//                               // }
//                             },
//                           ),
//                         ],
//                       );
//                     } else if (isNotesAvailable && currentIndex == 3) {
//                       // else if (actionStateValue == 3) {
//                       return IconButton(
//                         icon: const Icon(Icons.delete_forever),
//                         onPressed: () {
//                           // deletePermanentlyTheDeletedNotes(
//                           //     context, bottomNavBarProvider);
//                         },
//                       );
//                     } else {
//                       return const SizedBox.shrink();
//                     }
//                   })
//             ],
//           );
//         });
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return AppBar(
//   //       automaticallyImplyLeading: false,
//   //       title: const Text('Note App'),
//   //       actions: <Widget>[
//   //         ValueListenableBuilder<ActionStateValue>(
//   //             valueListenable:
//   //                 Provider.of<BottomNavBarProvider>(context, listen: false)
//   //                     .actionStateValue,
//   //             builder: (context, actionStateValue, child) {
//   //               print("Inside appbar actions");
//   //               if (actionStateValue.isNotesAvailable &&
//   //                   (actionStateValue.currentIndex == 0 ||
//   //                       actionStateValue.currentIndex == 1)) {
//   //                 return Row(
//   //                   children: [
//   //                     PopupMenuButton(
//   //                       icon: const Icon(Icons.sort),
//   //                       itemBuilder: (BuildContext context) => <PopupMenuEntry>[
//   //                         const PopupMenuItem(
//   //                           value: 'noteTitle',
//   //                           child: Text('Sort by Note Title'),
//   //                         ),
//   //                         const PopupMenuItem(
//   //                           value: 'location',
//   //                           child: Text('Sort by Location'),
//   //                         )
//   //                       ],
//   //                       onSelected: (selectedOption) {
//   //                         // bottomNavBarProvider.sortBy.value =
//   //                         //     selectedOption;
//   //                       },
//   //                     ),
//   //                     const SizedBox(width: 8),
//   //                     IconButton(
//   //                       icon: const Icon(Icons.delete),
//   //                       onPressed: () {
//   //                         // if (bottomNavBarProvider.noteKeys.isNotEmpty) {
//   //                         //   deleteSelectedNotes(context, bottomNavBarProvider);
//   //                         // }
//   //                       },
//   //                     ),
//   //                   ],
//   //                 );
//   //               } else if (actionStateValue.isNotesAvailable &&
//   //                   actionStateValue.currentIndex == 3) {
//   //                 return IconButton(
//   //                   icon: const Icon(Icons.delete_forever),
//   //                   onPressed: () {
//   //                     // deletePermanentlyTheDeletedNotes(
//   //                     //     context, bottomNavBarProvider);
//   //                   },
//   //                 );
//   //               } else {
//   //                 return const SizedBox.shrink();
//   //               }
//   //             })
//   //       ]);
//   // }
// }
