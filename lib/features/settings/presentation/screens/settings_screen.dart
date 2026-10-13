import 'package:flutter/material.dart' hide Text;
import 'package:egypt_guide/core/localization/app_text.dart';

import 'package:egypt_guide/core/localization/app_localizations.dart';
import 'package:egypt_guide/core/settings/app_settings_controller.dart';
import 'package:egypt_guide/core/widgets/aviation_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsController.instance;
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: settings,
      builder: (context, child) {
        return Scaffold(
          body: AviationBackground(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                    children: [
                      Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              context.tr('settings'),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(
                        icon: Icons.translate_rounded,
                        title: context.tr('choose_language'),
                      ),
                      const SizedBox(height: 10),
                      _SettingsOption(
                        icon: Icons.language_rounded,
                        title: context.tr('english'),
                        subtitle: 'English interface',
                        selected: !settings.isArabic,
                        onTap: () => settings.setLanguage('en'),
                      ),
                      const SizedBox(height: 9),
                      _SettingsOption(
                        icon: Icons.g_translate_rounded,
                        title: context.tr('arabic'),
                        subtitle: 'Full Arabic interface',
                        selected: settings.isArabic,
                        onTap: () => settings.setLanguage('ar'),
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(
                        icon: Icons.palette_outlined,
                        title: context.tr('choose_appearance'),
                      ),
                      const SizedBox(height: 10),
                      _SettingsOption(
                        icon: Icons.light_mode_rounded,
                        title: context.tr('light_mode'),
                        subtitle: 'Bright sky theme',
                        selected: !settings.isDarkMode,
                        onTap: () => settings.setThemeMode(ThemeMode.light),
                      ),
                      const SizedBox(height: 9),
                      _SettingsOption(
                        icon: Icons.dark_mode_rounded,
                        title: context.tr('dark_mode'),
                        subtitle: 'Night flight theme',
                        selected: settings.isDarkMode,
                        onTap: () => settings.setThemeMode(ThemeMode.dark),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.flight_rounded, color: colors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your language and theme are saved automatically.',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colors.primary),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SettingsOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primaryContainer
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: selected
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey('selected'),
                        color: colors.primary,
                      )
                    : Icon(
                        Icons.circle_outlined,
                        key: const ValueKey('not_selected'),
                        color: colors.outline,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
