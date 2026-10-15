import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todolist_firebase/firebase_options.dart';
import 'package:todolist_firebase/screen/auth_screen.dart';

Future<void> main (List<String> args) async {

  // Garantir o carregamento dos widgets do flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar o carregamento do Firebase
  await Firebase.initializeApp(
    // garante o carregamento do firebase na plataforma android (opcional quando se possui somente android no projeto)
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    home: AuthScreen(),
  ));
}