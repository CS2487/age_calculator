import 'package:age_calculator/screens/converter/date_converter_screen.dart';
import 'package:age_calculator/screens/home/home_screen.dart';
import 'package:age_calculator/screens/settings/settings_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _index = 0;

  final _pages = const [HomeScreen(), DateConverterScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0
            ? l10n.homeTitle
            : _index == 1
                ? l10n.convertTitle
                : l10n.settingsTitle),
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          HapticFeedback.selectionClick();
          setState(() => _index = i);
        },
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.calculate_outlined), label: l10n.navHome),
          NavigationDestination(
              icon: const Icon(Icons.swap_horiz_outlined),
              label: l10n.navConvert),
          NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              label: l10n.navSettings),
        ],
        indicatorColor: cs.primary.withOpacity(.10),
      ),
    );
  }
}
