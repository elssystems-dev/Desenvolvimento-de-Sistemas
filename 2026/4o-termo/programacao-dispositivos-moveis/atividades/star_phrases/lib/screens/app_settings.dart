import 'package:flutter/material.dart';
import 'package:star_phrases/theme/app_theme.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, currentMode, _) {
        final bool isDark = currentMode == ThemeMode.dark;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              "Configurações",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: SwitchListTile(
                  value: isDark,
                  onChanged: (bool value) {
                    AppTheme.toggleTheme(value);
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFFF8D830).withAlpha(40)
                          : Colors.amberAccent.withAlpha(80),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: isDark ? const Color(0xFFF8D830) : Colors.amber[800],
                    ),
                  ),
                  title: const Text(
                    "Modo Escuro",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    isDark ? "Tema escuro habilitado" : "Tema claro habilitado",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  activeThumbColor: const Color(0xFFF8D830),
                  activeTrackColor: Colors.amber[700],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}