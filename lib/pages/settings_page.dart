import 'package:flutter/material.dart';
import '../main.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final myAppState = MyApp.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        _buildSectionTitle('外观展示'),
        _buildCard(
          context,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('主题模式',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 16),
                    _buildThemeSegmentedControl(context, myAppState),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('主题配色', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _colorSeed(context, Colors.deepPurple),
                          _colorSeed(context, Colors.blue),
                          _colorSeed(context, Colors.green),
                          _colorSeed(context, Colors.red),
                          _colorSeed(context, Colors.orange),
                          _colorSeed(context, Colors.pink),
                          _colorSeed(context, Colors.teal),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('通用设置'),
        _buildCard(
          context,
          child: Column(
            children: [
              _buildSettingTile(
                context,
                icon: Icons.language_rounded,
                title: '语言设置',
                subtitle: '简体中文',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('语言设置功能开发中...')),
                  );
                },
              ),
              const Divider(height: 1),
              _buildSettingTile(
                context,
                icon: Icons.info_outline_rounded,
                title: '关于应用',
                subtitle: 'v1.0.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Project Butterfly',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSegmentedControl(BuildContext context, dynamic myAppState) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildThemeOption(context, myAppState, ThemeMode.system, '跟随系统', Icons.settings_brightness_rounded),
          _buildThemeOption(context, myAppState, ThemeMode.light, '浅色', Icons.light_mode_rounded),
          _buildThemeOption(context, myAppState, ThemeMode.dark, '深色', Icons.dark_mode_rounded),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, dynamic myAppState, ThemeMode mode, String label, IconData icon) {
    // 强制从 myAppState 获取最真实的状态
    final currentMode = myAppState.themeMode;
    final isSelected = currentMode == mode;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: () {
          myAppState.changeThemeMode(mode);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }

  Widget _colorSeed(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () => MyApp.of(context).changeSeedColor(color),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}
