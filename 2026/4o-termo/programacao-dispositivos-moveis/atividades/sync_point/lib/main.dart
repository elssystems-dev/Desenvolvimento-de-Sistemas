import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controllers/auth_controller.dart';
import 'services/api_service.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for dark immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1E293B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize REST API connection with json-server (safely with local fallback)
  await ApiService.initialize();

  runApp(const SyncPointApp());
}

class SyncPointApp extends StatefulWidget {
  const SyncPointApp({super.key});

  @override
  State<SyncPointApp> createState() => _SyncPointAppState();
}

class _SyncPointAppState extends State<SyncPointApp> {
  late final AuthController _authController;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _authController.init();
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _isInitializing
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : ListenableBuilder(
              listenable: _authController,
              builder: (context, _) {
                if (_authController.isAuthenticated) {
                  return HomeView(
                    authController: _authController,
                    onLogout: () async {
                      await _authController.logout();
                    },
                  );
                } else {
                  return LoginView(
                    authController: _authController,
                    onLoginSuccess: () {
                      setState(() {});
                    },
                  );
                }
              },
            ),
    );
  }
}
