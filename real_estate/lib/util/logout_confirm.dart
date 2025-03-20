import 'package:flutter/material.dart';

Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
  // return await showDialog<bool>(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Confirm Logout'),
  //           content: Text(
  //             'Are you sure you want to logout? All local data will be cleared.',
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(false),
  //               child: Text('Cancel'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () => Navigator.of(context).pop(true),
  //               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //               child: Text('Logout'),
  //             ),
  //           ],
  //         );
  //       },
  //     ) ??
  //     false;
}
