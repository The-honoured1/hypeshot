import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/editor_screen.dart';
import '../ui/screens/gallery_screen.dart';
import '../ui/screens/preview_screen.dart';
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
          path: '/editor',
          pageBuilder: (context, state) {
            if (state.extra is Map) {
              final chunks = state.extra as Map<String, dynamic>;
              final typedChunks = chunks.map((key, value) => MapEntry(key, value as String?));
              return NoTransitionPage(child: EditorScreen(chunks: typedChunks));
            }
            return NoTransitionPage(
              child: EditorScreen(videoPath: state.extra as String?),
            );
          },
        ),
        GoRoute(
          path: '/gallery',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: GalleryScreen(),
          ),
        ),
      ],
    ),
    // Preview stays fullscreen (outside shell)
    GoRoute(
      path: '/preview',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => PreviewScreen(videoPath: state.extra as String),
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

  static const _routes = ['/', '/editor', '/gallery'];

  @override
  Widget build(BuildContext context) {
    // Sync index with current route
    final location = GoRouterState.of(context).uri.toString();
    if (location == '/') {
      _currentIndex = 0;
    } else if (location.startsWith('/editor')) {
      _currentIndex = 1;
    } else if (location == '/gallery') {
      _currentIndex = 2;
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgElevated,
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(LucideIcons.home, 0),
                _navItem(LucideIcons.scissors, 1),
                _navItem(LucideIcons.layoutGrid, 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        context.go(_routes[index]);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppTheme.accentPrimary : AppTheme.textMuted,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 16 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: AppTheme.accentPrimary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
