import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/editor_screen.dart';
import '../ui/screens/gallery_screen.dart';
import '../ui/screens/preview_screen.dart';
import '../ui/screens/settings_screen.dart';
import 'theme.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/gallery',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: GalleryScreen(),
          ),
        ),
      ],
    ),
    // Fast Screens (Step 5, 6, 9) outside of shell for focus
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/preview',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PreviewScreen(videoPath: state.extra as String),
    ),
    GoRoute(
      path: '/editor',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        if (state.extra is Map) {
          final chunks = state.extra as Map<String, dynamic>;
          final typedChunks = chunks.map((key, value) => MapEntry(key, value as String?));
          return EditorScreen(chunks: typedChunks);
        }
        return EditorScreen(videoPath: state.extra as String?);
      },
    ),
  ],
);

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/') {
      _currentIndex = 0;
    } else if (location == '/gallery') {
      _currentIndex = 1;
    }

    return Scaffold(
      backgroundColor: AppTheme.bgInk,
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgSlate,
          border: Border(top: BorderSide(color: AppTheme.borderThin, width: 1)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(LucideIcons.home, 'HOME', 0, '/'),
              _navItem(LucideIcons.layoutGrid, 'GALLERY', 1, '/gallery'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, String route) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => context.go(route),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 60,
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppTheme.actionWhite : AppTheme.textDim,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: isActive ? AppTheme.actionWhite : AppTheme.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
