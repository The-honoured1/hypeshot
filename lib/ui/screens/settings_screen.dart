import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../providers/floating_button_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _bufferLength = 30;
  String _quality = 'HD';
  bool _autoSave = true;

  @override
  Widget build(BuildContext context) {
    final fbSettings = ref.watch(floatingButtonProvider);
    final fbNotifier = ref.read(floatingButtonProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgInk,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _sectionHeader('CAPTURER'),
          _buildModernTile(
            'BUFFER LENGTH',
            '${_bufferLength}S',
            LucideIcons.rotateCcw,
            onTap: () {
              setState(() {
                if (_bufferLength == 15) _bufferLength = 30;
                else if (_bufferLength == 30) _bufferLength = 60;
                else _bufferLength = 15;
              });
            },
          ),
          _buildModernTile(
            'VIDEO QUALITY',
            _quality,
            LucideIcons.monitor,
            onTap: () {
              setState(() {
                _quality = (_quality == 'HD') ? 'SD' : 'HD';
              });
            },
          ),
          const SizedBox(height: 32),
          _sectionHeader('FLOATING CONTROLS'),
          _buildActionToggle('CAPTURE', fbSettings.enabledActions.contains('capture'), (v) {
            final actions = List<String>.from(fbSettings.enabledActions);
            v ? actions.add('capture') : actions.remove('capture');
            fbNotifier.updateEnabledActions(actions);
          }),
          _buildActionToggle('PAUSE', fbSettings.enabledActions.contains('pause'), (v) {
            final actions = List<String>.from(fbSettings.enabledActions);
            v ? actions.add('pause') : actions.remove('pause');
            fbNotifier.updateEnabledActions(actions);
          }),
          _buildActionToggle('SCREENSHOT', fbSettings.enabledActions.contains('screenshot'), (v) {
            final actions = List<String>.from(fbSettings.enabledActions);
            v ? actions.add('screenshot') : actions.remove('screenshot');
            fbNotifier.updateEnabledActions(actions);
          }),
          _buildSliderSetting('OPACITY', fbSettings.opacity, (v) => fbNotifier.updateOpacity(v)),
          _buildSliderSetting('SCALE', fbSettings.sizeScale, (v) => fbNotifier.updateSizeScale(v), min: 0.8, max: 1.5),
          const SizedBox(height: 32),
          _sectionHeader('WORKFLOW'),
          _buildToggle(
            'AUTO-SAVE CLIPS',
            _autoSave,
            LucideIcons.save,
            (v) => setState(() => _autoSave = v),
          ),
          const SizedBox(height: 32),
          _sectionHeader('STORAGE'),
          _buildModernTile(
            'STORAGE LIMIT',
            '2.0 GB',
            LucideIcons.hardDrive,
            onTap: () {},
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              'HYPESHOT v1.0.0',
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppTheme.textDim, letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.textDim, letterSpacing: 2),
      ),
    );
  }

  Widget _buildModernTile(String title, String value, IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: AppTheme.studioCard(),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.textMain),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMain),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.accentAmber),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronRight, size: 14, color: AppTheme.textDim),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String title, bool value, IconData icon, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppTheme.studioCard(),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMain),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMain),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accentAmber,
            activeTrackColor: AppTheme.accentAmber.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildActionToggle(String title, bool value, Function(bool) onChanged) {
    return _buildToggle(title, value, LucideIcons.checkSquare, onChanged);
  }

  Widget _buildSliderSetting(String title, double value, Function(double) onChanged, {double min = 0.3, double max = 1.0}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppTheme.studioCard(),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              activeColor: AppTheme.accentAmber,
              onChanged: onChanged,
            ),
          ),
          Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.accentAmber)),
        ],
      ),
    );
  }
}
