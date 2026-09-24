import 'package:flutter/material.dart';

PreferredSizeWidget senaiAppBar({
  String title = "Senai Check-in",
  List<Widget>? actions,
  Widget? leading,
}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: const Color.fromARGB(255, 217, 36, 29),
    iconTheme: const IconThemeData(color: Colors.white),
    actions: actions,
    leading: leading,
    elevation: 2,
  );
}