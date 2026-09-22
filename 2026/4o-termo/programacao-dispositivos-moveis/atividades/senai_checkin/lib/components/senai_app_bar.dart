import 'package:flutter/material.dart';

PreferredSizeWidget senaiAppBar() {
  return AppBar(
    title: Text(
      "Senai Check-in",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold
      ),
    ),
    backgroundColor: const Color.fromARGB(255, 217, 36, 29),
  );
}