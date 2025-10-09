import 'package:age_calculator/utils/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri_date_time/hijri_date_time.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'age_result_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();

  bool _isSubmitting = false;
  String _calendarType = 'gregorian';

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _headerCard(l10n),
                const SizedBox(height: 16),
                _calendarTypeSelector(l10n),
                const SizedBox(height: 16),
                _buildDateFields(l10n),
                const SizedBox(height: 24),
                _buildCalculateButton(l10n),
                const SizedBox(height: 8),
                Text(
                  _calendarType == 'gregorian'
                      ? l10n.gregorianTip
                      : l10n.hijriTip,
                  style: TextStyle(color: cs.onSurface.withOpacity(.6)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCard(AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final subtitle = _calendarType == 'gregorian'
        ? l10n.gregorianSubtitle
        : l10n.hijriSubtitle;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.cake_rounded, color: cs.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.enterYourBirthDate,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.onSurface.withOpacity(.7)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendarTypeSelector(AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;

    Widget buildOption(String title, String type) {
      final selected = _calendarType == type;
      return Expanded(
        child: InkWell(
          onTap: () => _onCalendarTypeChanged(type),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? cs.primary.withOpacity(.1) : null,
              borderRadius: BorderRadius.circular(10),
              border: selected ? Border.all(color: cs.primary) : null,
            ),
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: selected ? cs.primary : cs.onSurface.withOpacity(.8),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            buildOption(l10n.gregorian, 'gregorian'),
            const SizedBox(width: 8),
            buildOption(l10n.hijri, 'hijri'),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFields(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: _dayController,
            label: l10n.day,
            fieldType: 'day',
            icon: Icons.calendar_today_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField(
            controller: _monthController,
            label: l10n.month,
            fieldType: 'month',
            icon: Icons.date_range_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField(
            controller: _yearController,
            label: l10n.year,
            fieldType: 'year',
            icon: Icons.calendar_month_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String fieldType,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(hintText: label, prefixIcon: Icon(icon)),
      keyboardType: TextInputType.number,
      textInputAction:
      fieldType == 'year' ? TextInputAction.done : TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(fieldType == 'year' ? 4 : 2),
      ],
      validator: (value) {
        final l10n = AppLocalizations.of(context)!;
        return _validateInput(fieldType, value, l10n);
      },
    );
  }

  String? _validateInput(String type, String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.fieldRequired;
    final n = int.tryParse(value);
    if (n == null) return l10n.enterValidNumber;
    return _calendarType == 'gregorian'
        ? _validateGregorian(type, n, l10n)
        : _validateHijri(type, n, l10n);
  }

  String? _validateGregorian(String type, int n, AppLocalizations l10n) {
    final currentYear = DateTime.now().year;
    switch (type) {
      case 'day':
        if (n < 1 || n > 31) return l10n.invalidDay;
        final m = int.tryParse(_monthController.text) ?? 0;
        if (!_isValidDayForMonth(n, m)) return l10n.invalidDay;
        break;
      case 'month':
        if (n < 1 || n > 12) return l10n.invalidMonth;
        break;
      case 'year':
        if (n < 1900 || n > currentYear) {
          return l10n.gregorianYearValidation(1900, currentYear);
        }
        break;
    }
    return null;
  }

  String? _validateHijri(String type, int n, AppLocalizations l10n) {
    final currentYear = HijriDateTime.now().year;
    switch (type) {
      case 'day':
        if (n < 1 || n > 30) return l10n.hijriDayValidation;
        break;
      case 'month':
        if (n < 1 || n > 12) return l10n.hijriMonthValidation;
        break;
      case 'year':
        if (n < 1300 || n > currentYear) {
          return l10n.hijriYearValidation(1300, currentYear);
        }
        break;
    }
    return null;
  }

  bool _isValidDayForMonth(int d, int m) {
    if (m < 1 || m > 12) return d <= 31;
    if (m == 2) {
      final y = int.tryParse(_yearController.text) ?? 0;
      final leap = (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
      return d <= (leap ? 29 : 28);
    }
    if (<int>{4, 6, 9, 11}.contains(m)) return d <= 30;
    return d <= 31;
  }

  void _onCalendarTypeChanged(String type) {
    setState(() {
      _calendarType = type;
      _formKey.currentState?.reset();
      _dayController.clear();
      _monthController.clear();
      _yearController.clear();
    });
  }

  Widget _buildCalculateButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: _isSubmitting
            ? const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white),
        )
            : const Icon(Icons.calculate_rounded),
        label: Text(l10n.calculateMyAge),
        onPressed: _isSubmitting ? null : _onCalculatePressed,
      ),
    );
  }

  Future<void> _onCalculatePressed() async {
    HapticFeedback.lightImpact();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 250));
    _processCalculation(context);
    setState(() => _isSubmitting = false);
  }

  void _processCalculation(BuildContext context) {
    final y = int.parse(_yearController.text);
    final m = int.parse(_monthController.text);
    final d = int.parse(_dayController.text);
    final l10n = AppLocalizations.of(context)!;

    try {
      DateTime birthDate;
      HijriDateTime? hijriBirthDate;

      if (_calendarType == 'gregorian') {
        birthDate = DateTime(y, m, d);
        hijriBirthDate = HijriDateTime.fromGregorian(birthDate);
      } else {
        hijriBirthDate = HijriDateTime(y, month: m, day: d);
        birthDate = hijriBirthDate.toGregorian();
      }

      if (birthDate.isAfter(DateTime.now())) {
        _showErrorDialog(context, l10n.futureDateError);
        return;
      }

      final ageDetails = _calculateDetailedAge(birthDate);
      final nextBirthday = _calculateNextBirthday(birthDate);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AgeResultScreen(
            ageDetails: ageDetails,
            nextBirthdayInfo: nextBirthday,
            birthDate: birthDate,
            hijriBirthDate: hijriBirthDate,
            calendarType: _calendarType,
          ),
        ),
      );
    } catch (_) {
      _showErrorDialog(context, l10n.invalidDateError);
    }
  }

  Map<String, dynamic> _calculateDetailedAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months--;
      final prevMonthLastDay = DateTime(now.year, now.month, 0).day;
      days += prevMonthLastDay;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    final diff = now.difference(birthDate);
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

  Map<String, dynamic> _calculateNextBirthday(DateTime birthDate) {
    final now = DateTime.now();
    DateTime next = DateTime(now.year, birthDate.month, birthDate.day);
    if (!next.isAfter(now)) {
      next = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }
    return {
      'date': next,
      'dayOfWeek': intl.DateFormat('EEEE').format(next),
    };
  }

  void _showErrorDialog(BuildContext context, String msg) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: l10n.error,
        message: msg,
        icon: Icons.error_outline,
        onClose: () => Navigator.pop(context),
      ),
    );
  }
}

