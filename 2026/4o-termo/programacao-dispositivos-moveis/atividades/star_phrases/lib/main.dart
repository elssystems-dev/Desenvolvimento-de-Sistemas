import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:star_phrases/firebase_options.dart';
import 'package:star_phrases/screens/phrases.dart';
import 'package:star_phrases/theme/app_theme.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const StarPhrasesApp());
}

class StarPhrasesApp extends StatelessWidget {
  const StarPhrasesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Star Phrases',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const Phrases(),
        );
      },
    );
  }
}