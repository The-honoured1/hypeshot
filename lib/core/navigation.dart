import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/profile_screen.dart';
import '../ui/screens/editor_screen.dart';
import '../ui/screens/feed_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/feed',
      builder: (context, state) => const FeedScreen(),
    ),
    GoRoute(
      path: '/editor',
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
