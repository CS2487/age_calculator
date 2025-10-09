import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // الاستماع للتغييرات في اللغة والمظهر
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeProvider.themeMode,

      locale: localeProvider.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'AE'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      home: const SplashScreen(),
    );

  }
}

class LocaleProvider with ChangeNotifier {
  Locale _locale;
  final SharedPreferences prefs;


  static const List<Locale> supportedLocales = [
    Locale('ar'), // Arabic
    Locale('en'), // English (or any other default)
  ];

  LocaleProvider(this.prefs)
      : _locale = Locale(prefs.getString('language_code') ?? 'ar') {
    _loadLocale();
  }

  Locale get locale => _locale;

  Future<void> _loadLocale() async {
    final languageCode = prefs.getString('language_code') ?? 'ar';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  void setLocale(Locale locale) {
    // 2. CHECK AGAINST THE STATIC LIST
    if (!LocaleProvider.supportedLocales.contains(locale)) return;

    _locale = locale;
    prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }

  bool get isArabic => _locale.languageCode == 'ar';
}
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode;
  final SharedPreferences prefs;

  ThemeProvider(this.prefs) : _themeMode = _getThemeModeFromPrefs(prefs);

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  static ThemeMode _getThemeModeFromPrefs(SharedPreferences prefs) {
    final themeString = prefs.getString('theme_mode') ?? 'system';
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void _saveThemeMode(ThemeMode mode) {
    prefs.setString('theme_mode', mode.name);
    _themeMode = mode;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _saveThemeMode(mode);
  }
}
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب الـ Providers للوصول إلى بياناتهم ووظائفهم
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final cs = Theme.of(context).colorScheme;

    // النصوص (بديل مؤقت لـ AppLocalizations)
    final bool isArabic = localeProvider.isArabic;
    final String helpTitle = isArabic ? 'المساعدة' : 'Help';
    final String helpMessage = isArabic
        ? 'من الصفحة الرئيسية يمكنك استخدام التطبيق لحساب عمرك بدقة ويُظهر تفاصيل كاملة وموعد عيد ميلادك القادم.'
        : 'From the main page, you can use the app to accurately calculate your age, view full details, and see your next birthday.';
    final String aboutTitle = isArabic ? 'حول التطبيق' : 'About App';
    final String aboutMessage = isArabic
        ? 'تطبيق "اعرف عمرك" يحسب عمرك بدقة ويُظهر تفاصيل كاملة.'
        : 'The "Know Your Age" app accurately calculates your age and shows complete details.';
    final String appName = isArabic ? 'اعرف عمرك' : 'Know Your Age';
    final String appDesc = isArabic ? 'لحساب العمر بدقة' : 'For accurate age calculation';


    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'الإعدادات' : 'Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // User Info Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: cs.primary,
                    child: Text(isArabic ? 'ع' : 'A',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 24)),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appName,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      Text(appDesc,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(.6))),
                    ],
                  )
                ],
              ),
            ),

            // --- Tiles for Theme and Language ---
            // تم استدعاء الدوال هنا لعرض الخيارات
            _themeTile(context, themeProvider, localeProvider.isArabic),
            _languageTile(context, localeProvider, localeProvider.isArabic),

            const Divider(),

            // Help Tile
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(helpTitle),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(helpTitle),
                  content: Text(helpMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(isArabic ? 'حسناً' : 'OK'),
                    ),
                  ],
                ),
              ),
            ),

            // About Tile
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(aboutTitle),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(aboutTitle),
                  content: Text(aboutMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(isArabic ? 'حسناً' : 'OK'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS FOR TILES ---
  // هذه الدوال تبني واجهة خيارات اللغة والمظهر

  Widget _themeTile(BuildContext context, ThemeProvider themeProvider, bool isArabic) {
    String themeName;
    switch (themeProvider.themeMode) {
      case ThemeMode.light:
        themeName = isArabic ? 'فاتح' : 'Light';
        break;
      case ThemeMode.dark:
        themeName = isArabic ? 'داكن' : 'Dark';
        break;
      default:
        themeName = isArabic ? 'نظام' : 'System';
    }
    return ListTile(
      leading: const Icon(Icons.dark_mode_outlined),
      title: Text(isArabic ? 'المظهر' : 'Theme'),
      subtitle: Text(themeName),
      onTap: () => _showThemeDialog(context, themeProvider, isArabic),
    );
  }

  Widget _languageTile(BuildContext context, LocaleProvider localeProvider, bool isArabic) =>
      ListTile(
        leading: const Icon(Icons.language_outlined),
        title: Text(isArabic ? 'اللغة' : 'Language'),
        subtitle: Text(localeProvider.isArabic ? 'العربية' : 'English'),
        onTap: () => _showLanguageDialog(context, localeProvider, isArabic),
      );

  // --- DIALOG FUNCTIONS ---
  // تم إضافة هذه الدوال لعرض نوافذ الاختيار

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isArabic ? 'اختر المظهر' : 'Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(isArabic ? 'فاتح' : 'Light'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(isArabic ? 'داكن' : 'Dark'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(isArabic ? 'نظام' : 'System'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) themeProvider.setThemeMode(value);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, LocaleProvider localeProvider, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isArabic ? 'اختر اللغة' : 'Choose Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: const Text('العربية'),
                value: const Locale('ar', 'AE'),
                groupValue: localeProvider.locale,
                onChanged: (value) {
                  if (value != null) localeProvider.setLocale(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<Locale>(
                title: const Text('English'),
                value: const Locale('en', 'US'),
                groupValue: localeProvider.locale,
                onChanged: (value) {
                  if (value != null) localeProvider.setLocale(value);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class AppThemes {
  static const Color primary = Color(0xFF2C3E50);
  static const Color error = Colors.red;
  static const Color background = Colors.white;
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        error: error,
        surface: background, // ✅ استبدلنا background بـ surface
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: background,
        scrolledUnderElevation: 0,
      ),
      cardTheme: const CardTheme(
        elevation: 1,
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: error),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        error: error,
        surface: const Color(0xFF111111), // ✅ هنا أيضاً استخدمنا surface
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardTheme(
        elevation: 1,
        color: Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111111),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: error),
        ),
      ),
    );
  }
}
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _go(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, a, __) =>
              FadeTransition(opacity: a, child: const BottomNavBar()),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _go(context); // استدعاء الانتقال مباشرة بعد البناء
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withOpacity(.08),
              cs.primary.withOpacity(.25),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(.35),
                      blurRadius: 24,
                      spreadRadius: 6,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.access_time_outlined,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'مرحباً بك في "اعرف عمرك"',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'لنحسب عمرك بدقة وسلاسة',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _index = 0;

  final _pages = const [
    AgeCalculatorScreen(),
    DateConverterScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0
            ? 'اعرف عمرك'
            : _index == 1
            ? 'تحويل التاريخ'
            : 'حول ومساعدة'),
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          HapticFeedback.selectionClick();
          setState(() => _index = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'تحويل',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'حول',
          ),
        ],
        indicatorColor: cs.primary.withOpacity(.10),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onClose;
  final Color? iconColor;
  final Color? buttonColor;
  const CustomDialog(
      {super.key,
        required this.title,
        required this.message,
        required this.icon,
        required this.onClose,
        this.iconColor,
        this.buttonColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: iconColor ?? cs.primary),
            const SizedBox(height: 16),
            Text(title,
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(message,
                style: TextStyle(
                    fontSize: 15, color: cs.onSurface.withOpacity(.75)),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor ?? cs.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('إغلاق',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateConverterScreen extends StatefulWidget {
  const DateConverterScreen({super.key});

  @override
  State<DateConverterScreen> createState() => _DateConverterScreenState();
}

class _DateConverterScreenState extends State<DateConverterScreen> {
  final _gregorianDayController = TextEditingController();
  final _gregorianMonthController = TextEditingController();
  final _gregorianYearController = TextEditingController();

  final _hijriDayController = TextEditingController();
  final _hijriMonthController = TextEditingController();
  final _hijriYearController = TextEditingController();

  String _conversionResult = '';
  String _conversionType = 'gregorian_to_hijri';

  @override
  void dispose() {
    _gregorianDayController.dispose();
    _gregorianMonthController.dispose();
    _gregorianYearController.dispose();
    _hijriDayController.dispose();
    _hijriMonthController.dispose();
    _hijriYearController.dispose();
    super.dispose();
  }

  void _convertDate() {
    try {
      if (_conversionType == 'gregorian_to_hijri') {
        final day = int.parse(_gregorianDayController.text);
        final month = int.parse(_gregorianMonthController.text);
        final year = int.parse(_gregorianYearController.text);

        final gregorianDate = DateTime(year, month, day);
        if (gregorianDate.year != year ||
            gregorianDate.month != month ||
            gregorianDate.day != day) {
          throw Exception('invalid date');
        }

        final hijriDate = HijriDateTime.fromGregorian(gregorianDate);

        setState(() {
          _conversionResult =
          'التاريخ الهجري: ${hijriDate.day}/${hijriDate.month}/${hijriDate.year} هـ';
          _hijriDayController.text = hijriDate.day.toString();
          _hijriMonthController.text = hijriDate.month.toString();
          _hijriYearController.text = hijriDate.year.toString();
        });
      } else {
        final day = int.parse(_hijriDayController.text);
        final month = int.parse(_hijriMonthController.text);
        final year = int.parse(_hijriYearController.text);

        final hijriDate = HijriDateTime(year, month: month, day: day);
        if (hijriDate.day != day || hijriDate.month != month) {
          throw Exception('invalid hijri date');
        }
        final gregorianDate = hijriDate.toGregorian();

        setState(() {
          _conversionResult =
          'التاريخ الميلادي: ${gregorianDate.day}/${gregorianDate.month}/${gregorianDate.year} م';
          _gregorianDayController.text = gregorianDate.day.toString();
          _gregorianMonthController.text = gregorianDate.month.toString();
          _gregorianYearController.text = gregorianDate.year.toString();
        });
      }
    } catch (e) {
      setState(() {
        _conversionResult = 'خطأ: تاريخ غير صالح';
      });
    }
  }

  void _clearFields() {
    _gregorianDayController.clear();
    _gregorianMonthController.clear();
    _gregorianYearController.clear();
    _hijriDayController.clear();
    _hijriMonthController.clear();
    _hijriYearController.clear();
    setState(() {
      _conversionResult = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _conversionType = 'gregorian_to_hijri';
                            _clearFields();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _conversionType == 'gregorian_to_hijri'
                                ? cs.primary.withOpacity(.1)
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            border: _conversionType == 'gregorian_to_hijri'
                                ? Border.all(color: cs.primary)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'ميلادي إلى هجري',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _conversionType == 'gregorian_to_hijri'
                                    ? cs.primary
                                    : cs.onSurface.withOpacity(.8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _conversionType = 'hijri_to_gregorian';
                            _clearFields();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _conversionType == 'hijri_to_gregorian'
                                ? cs.primary.withOpacity(.1)
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            border: _conversionType == 'hijri_to_gregorian'
                                ? Border.all(color: cs.primary)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'هجري إلى ميلادي',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _conversionType == 'hijri_to_gregorian'
                                    ? cs.primary
                                    : cs.onSurface.withOpacity(.8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_conversionType == 'gregorian_to_hijri') ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _gregorianDayController,
                      decoration: const InputDecoration(
                        hintText: 'اليوم',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _gregorianMonthController,
                      decoration: const InputDecoration(
                        hintText: 'الشهر',
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _gregorianYearController,
                      decoration: const InputDecoration(
                        hintText: 'السنة',
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('أدخل التاريخ الميلادي',
                  style: TextStyle(color: cs.onSurface.withOpacity(.6))),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hijriDayController,
                      decoration: const InputDecoration(
                        hintText: 'اليوم',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _hijriMonthController,
                      decoration: const InputDecoration(
                        hintText: 'الشهر',
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _hijriYearController,
                      decoration: const InputDecoration(
                        hintText: 'السنة',
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('أدخل التاريخ الهجري',
                  style: TextStyle(color: cs.onSurface.withOpacity(.6))),
            ],
            const SizedBox(height: 20),
            if (_conversionResult.isNotEmpty)
              Card(
                color: cs.primary.withOpacity(.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_conversionResult,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: cs.primary)),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50, // 👈 توحيد الارتفاع
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // 👈 نفس الانحناء لو أردت
                        ),
                      ),
                      onPressed: _clearFields,
                      child: const Text('مسح', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 50, // 👈 نفس الارتفاع
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _convertDate,
                      child:
                      const Text('تحويل', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}


class AgeCalculatorScreen extends StatelessWidget {
  const AgeCalculatorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: AgeForm());
  }
}

class AgeForm extends StatefulWidget {
  const AgeForm({super.key});
  @override
  State<AgeForm> createState() => _AgeFormState();
}

class _AgeFormState extends State<AgeForm> {
  final _formKey = GlobalKey<FormState>();
  final _day = TextEditingController();
  final _month = TextEditingController();
  final _year = TextEditingController();
  bool _submitting = false;

  String _calendarType = 'gregorian';

  @override
  void dispose() {
    _day.dispose();
    _month.dispose();
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _HeaderCard(calendarType: _calendarType),
            const SizedBox(height: 16),
            _CalendarTypeSelector(
              currentType: _calendarType,
              onChanged: (type) {
                setState(() {
                  _calendarType = type;
                  _formKey.currentState?.reset();
                  _day.clear();
                  _month.clear();
                  _year.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildTextField(
                        _day, 'اليوم', 'day', Icons.calendar_today_rounded)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildTextField(
                        _month, 'الشهر', 'month', Icons.date_range_rounded)),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildTextField(
                        _year, 'السنة', 'year', Icons.calendar_month_rounded)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _submitting
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.calculate_rounded),
                label: const Text('احسب عمري'),
                onPressed: _submitting
                    ? null
                    : () async {
                  HapticFeedback.lightImpact();
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  setState(() => _submitting = true);
                  await Future.delayed(const Duration(milliseconds: 250));
                  _calculate(context);
                  setState(() => _submitting = false);
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _calendarType == 'gregorian'
                  ? 'نصائح: أدخل تاريخ ميلادك الصحيح بالتقويم الميلادي.'
                  : 'نصائح: أدخل تاريخ ميلادك الصحيح بالتقويم الهجري.',
              style: TextStyle(color: cs.onSurface.withOpacity(.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController c, String hint, String type, IconData icon) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
      keyboardType: TextInputType.number,
      textInputAction:
      type == 'year' ? TextInputAction.done : TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(type == 'year' ? 4 : 2),
      ],
      validator: (value) => _validate(type, value),
    );
  }

  String? _validate(String type, String? v) {
    if (v == null || v.trim().isEmpty) return 'هذا الحقل مطلوب';
    final n = int.tryParse(v);
    if (n == null) return 'الرجاء إدخال رقم صحيح';

    if (_calendarType == 'gregorian') {
      switch (type) {
        case 'day':
          if (n < 1 || n > 31) return 'ادخال خاطئ';
          if (_month.text.isNotEmpty) {
            final m = int.tryParse(_month.text) ?? 0;
            if (!_isValidDayForMonth(n, m)) return 'ادخال خاطئ';
          }
          break;
        case 'month':
          if (n < 1 || n > 12) return 'ادخال خاطئ';
          break;
        case 'year':
          final currentYear = DateTime.now().year;
          if (n < 1900 || n > currentYear) {
            return 'السنة يجب أن تكون بين 1900 و $currentYear';
          }
          break;
      }
    } else {
      final currentYear = HijriDateTime.now().year;
      switch (type) {
        case 'day':
          if (n < 1 || n > 30) return 'اليوم الهجري يجب أن يكون بين 1 و 30';
          break;
        case 'month':
          if (n < 1 || n > 12) return 'الشهر الهجري يجب أن يكون بين 1 و 12';
          break;
        case 'year':
          if (n < 1300 || n > currentYear) {
            return 'السنة يجب أن تكون بين 1300 و $currentYear';
          }
          break;
      }
    }
    return null;
  }

  bool _isValidDayForMonth(int d, int m) {
    if (m == 2) {
      if (_year.text.isNotEmpty) {
        final y = int.tryParse(_year.text) ?? 0;
        final leap = (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
        return d <= (leap ? 29 : 28);
      }
      return d <= 29;
    }
    if (<int>{4, 6, 9, 11}.contains(m)) return d <= 30;
    return d <= 31;
  }

  void _calculate(BuildContext context) {
    final y = int.parse(_year.text);
    final m = int.parse(_month.text);
    final d = int.parse(_day.text);

    DateTime birthDate;
    HijriDateTime? hijriBirthDate;

    try {
      if (_calendarType == 'gregorian') {
        birthDate = DateTime(y, m, d);
        if (birthDate.year != y || birthDate.month != m || birthDate.day != d) {
          throw Exception('invalid date');
        }
        hijriBirthDate = HijriDateTime.fromGregorian(birthDate);
      } else {
        hijriBirthDate = HijriDateTime(y, month: m, day: d);
        if (hijriBirthDate.month != m || hijriBirthDate.day != d) {
          throw Exception('invalid hijri date construction');
        }
        birthDate = hijriBirthDate.toGregorian();
      }
    } catch (_) {
      _showError(context, 'تاريخ الميلاد غير صالح');
      return;
    }

    final now = DateTime.now();
    if (birthDate.isAfter(now)) {
      _showError(context, 'تاريخ الميلاد لا يمكن أن يكون في المستقبل');
      return;
    }

    final age = _computeDetailedAge(birthDate, now);
    final nextInfo = _computeNextBirthday(birthDate, now);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AgeResultScreen(
          ageDetails: age,
          nextBirthdayInfo: nextInfo,
          birthDate: birthDate,
          hijriBirthDate: hijriBirthDate,
          calendarType: _calendarType),
    ));
  }

  Map<String, dynamic> _computeDetailedAge(DateTime birth, DateTime now) {
    int years = now.year - birth.year;
    int months = now.month - birth.month;
    int days = now.day - birth.day;

    if (days < 0) {
      months--;
      final prevMonthLastDay = DateTime(now.year, now.month, 0).day;
      days += prevMonthLastDay;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    final diff = now.difference(birth);
    return {
      'years': years,
      'months': months,
      'days': days,
      'totalMonths': years * 12 + months,
      'totalDays': diff.inDays,
      'totalHours': diff.inHours,
      'totalMinutes': diff.inMinutes,
      'totalSeconds': diff.inSeconds,
    };
  }

  Map<String, dynamic> _computeNextBirthday(DateTime birth, DateTime now) {
    DateTime next = DateTime(now.year, birth.month, birth.day);
    if (!next.isAfter(now)) {
      next = DateTime(now.year + 1, birth.month, birth.day);
    }
    if (birth.month == 2 && birth.day == 29) {
      final isLeap = ((next.year % 4 == 0) && (next.year % 100 != 0)) ||
          (next.year % 400 == 0);
      if (!isLeap) {
        next = DateTime(next.year, 2, 28);
      }
    }

    final diff = next.difference(now);
    return {
      'date': next,
      'inMonths': diff.inDays ~/ 30,
      'daysRemaining': diff.inDays,
      'hoursRemaining': diff.inHours % 24,
      'minutesRemaining': diff.inMinutes % 60,
      'secondsRemaining': diff.inSeconds % 60,
      'dayOfWeek': intl.DateFormat('EEEE').format(next),
    };
  }

  void _showError(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: 'خطأ',
        message: msg,
        icon: Icons.error_outline,
        onClose: () => Navigator.pop(context),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String calendarType;
  const _HeaderCard({required this.calendarType});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final String subtitle = calendarType == 'gregorian'
        ? 'نستخدم التقويم الميلادي ونراعي السنوات الكبيسة.'
        : 'أدخل التاريخ وفق التقويم الهجري.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: cs.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.cake_rounded, color: cs.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أدخل تاريخ ميلادك',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: cs.onSurface.withOpacity(.7))),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarTypeSelector extends StatelessWidget {
  final String currentType;
  final ValueChanged<String> onChanged;
  const _CalendarTypeSelector(
      {required this.currentType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildOption(
                context,
                'ميلادي',
                'gregorian',
                currentType == 'gregorian',
                cs,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildOption(
                context,
                'هجري',
                'hijri',
                currentType == 'hijri',
                cs,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, String type,
      bool isSelected, ColorScheme cs) {
    return InkWell(
      onTap: () => onChanged(type),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withOpacity(.1) : null,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: cs.primary) : null,
        ),
        child: Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? cs.primary : cs.onSurface.withOpacity(.8),
            ),
          ),
        ),
      ),
    );
  }
}

class AgeResultScreen extends StatefulWidget {
  final Map<String, dynamic> ageDetails;
  final Map<String, dynamic> nextBirthdayInfo;
  final DateTime birthDate;
  final HijriDateTime? hijriBirthDate;
  final String calendarType;

  const AgeResultScreen(
      {super.key,
        required this.ageDetails,
        required this.nextBirthdayInfo,
        required this.birthDate,
        this.hijriBirthDate,
        required this.calendarType});

  @override
  State<AgeResultScreen> createState() => _AgeResultScreenState();
}

class _AgeResultScreenState extends State<AgeResultScreen> {
  final Map<String, String> _arDays = const {
    'Sunday': 'الأحد',
    'Monday': 'الاثنين',
    'Tuesday': 'الثلاثاء',
    'Wednesday': 'الأربعاء',
    'Thursday': 'الخميس',
    'Friday': 'الجمعة',
    'Saturday': 'السبت',
  };

  String _ar(String en) => _arDays[en] ?? en;

  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    final next = widget.nextBirthdayInfo['date'] as DateTime;
    _remaining = next.difference(DateTime.now());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = next.difference(DateTime.now());
      if (!mounted) return;
      setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
    });
  }

  void _shareResult() {
    // استخراج تفاصيل العمر من الويدجت
    final years = widget.ageDetails['years'];
    final months = widget.ageDetails['months'];
    final days = widget.ageDetails['days'];

    // إنشاء النص الذي سيتم مشاركته
    final String shareText = '''
🎉 لقد حسبت عمري للتو عبر تطبيق "اعرف عمرك"! 🎉

عمري بالتفصيل هو:
$years سنة، و $months شهر، و $days يوم.

اكتشف عمرك بدقة أنت أيضاً!
حمل تطبيق "اعرف عمرك" الآن.
''';
    Share.share(shareText, subject: 'اكتشف عمري مع تطبيق "اعرف عمرك"');
  }

  String _getHijriDayName(HijriDateTime hijriDate) {
    final gregorianDate = hijriDate.toGregorian();
    final englishDay = intl.DateFormat('EEEE').format(gregorianDate);
    return _ar(englishDay);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('نتيجة حساب عمرك'),

        // زر المشاركة لا يزال كما هو
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareResult,
            tooltip: 'مشاركة النتيجة',
          ),
        ],
      ),
      // -->> تعديل: تم حذف ويدجت الـ Screenshot من هنا
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            _AgeHeroCard(age: widget.ageDetails),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: cs.primary),
                        const SizedBox(width: 8),
                        const Text('تفاصيل تاريخ الميلاد',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('الميلادي',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: cs.primary)),
                            Text(intl.DateFormat('yyyy/MM/dd')
                                .format(widget.birthDate)),
                            Text(_ar(intl.DateFormat('EEEE')
                                .format(widget.birthDate))),
                          ],
                        ),
                        Column(
                          children: [
                            Text('الهجري',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: cs.primary)),
                            if (widget.hijriBirthDate != null) ...[
                              Text(
                                  '${widget.hijriBirthDate!.year}/${widget.hijriBirthDate!.month}/${widget.hijriBirthDate!.day}'),
                              Text(_getHijriDayName(widget.hijriBirthDate!)),
                            ] else ...[
                              const Text('--/--/--'),
                              const Text('--'),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _StatsGrid(age: widget.ageDetails),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: cs.primary.withOpacity(.12),
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.event_available_outlined,
                                color: cs.primary),
                          ),
                          const SizedBox(width: 10),
                          const Text('عيد الميلاد القادم',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                          'وُلدت يوم ${_ar(intl.DateFormat('EEEE').format(widget.birthDate))}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(
                          'سيكون عيد ميلادك يوم ${_ar(widget.nextBirthdayInfo['dayOfWeek'])}'),
                      const SizedBox(height: 6),
                      Text(
                          'التاريخ: ${intl.DateFormat('yyyy-MM-dd').format(widget.nextBirthdayInfo['date'])}'),
                      const SizedBox(height: 12),
                      _CountdownStrip(remaining: _remaining),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeHeroCard extends StatelessWidget {
  final Map<String, dynamic> age;
  const _AgeHeroCard({required this.age});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: cs.primary.withOpacity(.12),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.hourglass_bottom_rounded, color: cs.primary),
              ),
              const SizedBox(width: 12),
              const Text('عمرك الحالي',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
              '${age['years']} سنة و ${age['months']} شهر و ${age['days']} يوم',
              style: const TextStyle(fontSize: 18)),
        ]),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> age;
  const _StatsGrid({required this.age});
  @override
  Widget build(BuildContext context) {
    final items = [
      (
      'الشهور الكلية',
      Icons.calendar_view_month_rounded,
      age['totalMonths'].toString()
      ),
      ('الأيام الكلية', Icons.today_rounded, age['totalDays'].toString()),
      (
      'الساعات الكلية',
      Icons.access_time_rounded,
      age['totalHours'].toString()
      ),
      ('الدقائق الكلية', Icons.timer_rounded, age['totalMinutes'].toString()),
      (
      'الثواني الكلية',
      Icons.timelapse_rounded,
      age['totalSeconds'].toString()
      ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, c) {
            final isNarrow = c.maxWidth < 360;
            final cross = isNarrow ? 2 : 3;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                mainAxisExtent: 92,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (_, i) {
                final (title, icon, value) = items[i];
                return _StatTile(title: title, icon: icon, value: value);
              },
            );
          },
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  const _StatTile(
      {required this.title, required this.icon, required this.value});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(.2)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: cs.primary),
          const Spacer(),
          Text(value,
              style:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ]),
        const Spacer(),
        Text(title,
            style:
            TextStyle(color: cs.onSurface.withOpacity(.7), fontSize: 12)),
      ]),
    );
  }
}

class _CountdownStrip extends StatelessWidget {
  final Duration remaining;
  const _CountdownStrip({required this.remaining});
  @override
  Widget build(BuildContext context) {
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withOpacity(.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _timeBox(label: 'أيام', value: days),
          _sep(),
          _timeBox(label: 'ساعات', value: hours),
          _sep(),
          _timeBox(label: 'دقائق', value: minutes),
          _sep(),
          _timeBox(label: 'ثوانٍ', value: seconds),
        ],
      ),
    );
  }

  Widget _sep() => const Text(':',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  Widget _timeBox({required String label, required int value}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value.toString().padLeft(2, '0'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
