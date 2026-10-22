import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:star_phrases/firebase_options.dart';

import 'package:star_phrases/screens/phrases.dart';

Future<void> main(List<String> args) async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Phrases(),
    )
  );
}