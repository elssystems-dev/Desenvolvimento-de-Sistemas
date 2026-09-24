import 'package:flutter/material.dart';
import 'package:senai_checkin/view/log_history.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'SENAI Check-In',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD9241D),
        primary: const Color(0xFFD9241D),
      ),
      useMaterial3: true,
    ),
    home: const LogHistory(),
  ));
}