import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _bufferLength = 30;
  String _quality = 'HD';
  bool _autoSave = true;

  @override
  Widget build(BuildContext context) {
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
}
