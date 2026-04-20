import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/navigation.dart';
import 'ui/widgets/mesh_background.dart';

void main() {
  runApp(
    const ProviderScope(
      child: HypeShotApp(),
    ),
  );
}

class HypeShotApp extends StatelessWidget {
  const HypeShotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HypeShot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
      builder: (context, child) {
        return Scaffold(
          body: MeshBackground(child: child ?? const SizedBox()),
        );
      },
    );
  }
}
