import 'package:age_calculator/providers/locale_provider.dart';
import 'package:age_calculator/utils/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.help),
            onTap: () => showDialog(
              context: context,
              builder: (_) => CustomDialog(
                title: l10n.help,
                message: l10n.helpMsg,
                icon: Icons.help_outline,
                onClose: () => Navigator.pop(context),
                iconColor: cs.primary,
                buttonColor: cs.primary,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            onTap: () => showDialog(
              context: context,
              builder: (_) => CustomDialog(
                title: l10n.about,
                message: l10n.aboutMsg,
                icon: Icons.info_outline,
                onClose: () => Navigator.pop(context),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.chooseLanguage),
            onTap: () => showDialog(
                context: context, builder: (_) => _languageDialog(context)),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l10n.chooseTheme),
            onTap: () => showDialog(
                context: context, builder: (_) => _themeDialog(context)),
          ),
        ],
      ),
    );
  }

  Widget _languageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lp = context.read<LocaleProvider>();
    final current = context.watch<LocaleProvider>().locale.languageCode;

    return AlertDialog(
      title: Text(l10n.chooseLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: const Text('العربية'),
            value: 'ar',
            groupValue: current,
            onChanged: (v) {
              lp.setLocale(const Locale('ar'));
              Navigator.pop(context);
            },
          ),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: current,
            onChanged: (v) {
              lp.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _themeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tp = context.read<ThemeProvider>();
    final currentMode = context.watch<ThemeProvider>().mode;

    return AlertDialog(
      title: Text(l10n.chooseTheme),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeSystem),
            value: ThemeMode.system,
            groupValue: currentMode,
            onChanged: (v) {
              tp.setMode(v!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeLight),
            value: ThemeMode.light,
            groupValue: currentMode,
            onChanged: (v) {
              tp.setMode(v!);
              Navigator.pop(context);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeDark),
            value: ThemeMode.dark,
            groupValue: currentMode,
            onChanged: (v) {
              tp.setMode(v!);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
