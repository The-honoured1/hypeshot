import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FloatingButtonSettings {
  final List<String> enabledActions;
  final double opacity;
  final double sizeScale;

  FloatingButtonSettings({
    required this.enabledActions,
    required this.opacity,
    required this.sizeScale,
  });

  FloatingButtonSettings copyWith({
    List<String>? enabledActions,
    double? opacity,
    double? sizeScale,
  }) {
    return FloatingButtonSettings(
      enabledActions: enabledActions ?? this.enabledActions,
      opacity: opacity ?? this.opacity,
      sizeScale: sizeScale ?? this.sizeScale,
    );
  }
}

class FloatingButtonNotifier extends Notifier<FloatingButtonSettings> {
  static const String _kEnabledActions = 'fb_enabled_actions';
  static const String _kOpacity = 'fb_opacity';
  static const String _kSizeScale = 'fb_size_scale';

  @override
  FloatingButtonSettings build() {
    _loadSettings();
    return FloatingButtonSettings(
      enabledActions: ['capture', 'pause', 'screenshot', 'stop'],
      opacity: 1.0,
      sizeScale: 1.0,
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final actions = prefs.getStringList(_kEnabledActions) ?? ['capture', 'pause', 'screenshot', 'stop'];
    final opacity = prefs.getDouble(_kOpacity) ?? 1.0;
    final sizeScale = prefs.getDouble(_kSizeScale) ?? 1.0;
    state = FloatingButtonSettings(
      enabledActions: actions,
      opacity: opacity,
      sizeScale: sizeScale,
    );
  }

  Future<void> updateEnabledActions(List<String> actions) async {
    state = state.copyWith(enabledActions: actions);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kEnabledActions, actions);
    await FlutterOverlayWindow.shareData("REFRESH");
  }

  Future<void> updateOpacity(double opacity) async {
    state = state.copyWith(opacity: opacity);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kOpacity, opacity);
    await FlutterOverlayWindow.shareData("REFRESH");
  }

  Future<void> updateSizeScale(double scale) async {
    state = state.copyWith(sizeScale: scale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kSizeScale, scale);
    await FlutterOverlayWindow.shareData("REFRESH");
  }
}

final floatingButtonProvider = NotifierProvider<FloatingButtonNotifier, FloatingButtonSettings>(FloatingButtonNotifier.new);
