import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/location_controller.dart';
import '../../controllers/punch_clock_controller.dart';
import '../../controllers/workplace_controller.dart';
import '../../utils/app_colors.dart';
import '../profile/profile_view.dart';
import '../settings/workplace_settings_view.dart';
import 'history_view.dart';
import 'punch_clock_view.dart';

class HomeView extends StatefulWidget {
  final AuthController authController;
  final VoidCallback onLogout;

  const HomeView({
    super.key,
    required this.authController,
    required this.onLogout,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  late final PunchClockController _punchClockController;
  late final LocationController _locationController;
  late final WorkplaceController _workplaceController;
  late final HistoryController _historyController;

  @override
  void initState() {
    super.initState();
    _punchClockController = PunchClockController();
    _locationController = LocationController();
    _workplaceController = WorkplaceController();
    _historyController = HistoryController();

    _initControllers();
  }

  Future<void> _initControllers() async {
    await _workplaceController.loadWorkplace();
    await _locationController.checkLocation(_workplaceController.activeWorkplace);

    if (widget.authController.currentUser != null) {
      await _historyController.loadRecords(widget.authController.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _punchClockController.dispose();
    _locationController.dispose();
    _workplaceController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      PunchClockView(
        authController: widget.authController,
        punchClockController: _punchClockController,
        locationController: _locationController,
        workplaceController: _workplaceController,
        historyController: _historyController,
        onNavigateToWorkplaceSettings: () {
          setState(() {
            _currentIndex = 2; // Jump to workplace tab
          });
        },
      ),
      HistoryView(
        authController: widget.authController,
        historyController: _historyController,
      ),
      WorkplaceSettingsView(
        workplaceController: _workplaceController,
        locationController: _locationController,
      ),
      ProfileView(
        authController: widget.authController,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.5), width: 0.8),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabChanged,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.fingerprint_rounded),
              activeIcon: Icon(Icons.fingerprint_rounded, size: 28),
              label: 'Ponto',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              activeIcon: Icon(Icons.receipt_long_rounded, size: 28),
              label: 'Histórico',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.radar_rounded),
              activeIcon: Icon(Icons.radar_rounded, size: 28),
              label: 'Perímetro',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded, size: 28),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
