import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:senai_checkin/components/senai_app_bar.dart';

class LogHistory extends StatefulWidget {
  const LogHistory({super.key});

  @override
  State<LogHistory> createState() => _LogHistoryState();
}

class _LogHistoryState extends State<LogHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: senaiAppBar()
    );
  }
}