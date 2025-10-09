import 'package:flutter/material.dart';
import 'package:hijri_date_time/hijri_date_time.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    // دالة مساعدة لتنسيق النصوص
    String formatDate(String template, int day, int month, int year) {
      return template
          .replaceAll('{day}', day.toString())
          .replaceAll('{month}', month.toString())
          .replaceAll('{year}', year.toString());
    }

    try {
      if (_conversionType == 'gregorian_to_hijri') {
        final day = int.parse(_gregorianDayController.text.trim());
        final month = int.parse(_gregorianMonthController.text.trim());
        final year = int.parse(_gregorianYearController.text.trim());

        final gregorianDate = DateTime(year, month, day);
        if (gregorianDate.year != year ||
            gregorianDate.month != month ||
            gregorianDate.day != day) {
          throw Exception('invalid date');
        }

        final hijriDate = HijriDateTime.fromGregorian(gregorianDate);

        setState(() {
          _conversionResult = l10n.resultGregorian(
            gregorianDate.day,
            gregorianDate.month,
            gregorianDate.year,
          );


          _hijriDayController.text = hijriDate.day.toString();
          _hijriMonthController.text = hijriDate.month.toString();
          _hijriYearController.text = hijriDate.year.toString();
        });
      } else {
        final day = int.parse(_hijriDayController.text.trim());
        final month = int.parse(_hijriMonthController.text.trim());
        final year = int.parse(_hijriYearController.text.trim());

        final hijriDate = HijriDateTime(year, month: month, day: day);
        if (hijriDate.day != day || hijriDate.month != month) {
          throw Exception('invalid hijri date');
        }
        final gregorianDate = hijriDate.toGregorian();

        setState(() {
          _conversionResult = l10n.resultGregorian(
            gregorianDate.day,
            gregorianDate.month,
            gregorianDate.year,
          );

          _gregorianDayController.text = gregorianDate.day.toString();
          _gregorianMonthController.text = gregorianDate.month.toString();
          _gregorianYearController.text = gregorianDate.year.toString();
        });
      }
    } catch (e) {
      setState(() {
        _conversionResult = l10n.errorInvalidDate;
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
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 اختيار نوع التحويل
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
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
                        child: _buildTypeButton(
                          isSelected: _conversionType == 'gregorian_to_hijri',
                          text: l10n.gToH,
                          colorScheme: cs,
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
                        child: _buildTypeButton(
                          isSelected: _conversionType == 'hijri_to_gregorian',
                          text: l10n.hToG,
                          colorScheme: cs,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 حقول الإدخال
            if (_conversionType == 'gregorian_to_hijri')
              _buildDateInputs(
                dayController: _gregorianDayController,
                monthController: _gregorianMonthController,
                yearController: _gregorianYearController,
                dayHint: l10n.day,
                monthHint: l10n.month,
                yearHint: l10n.year,
                subtitle: l10n.enterGregorian,
                cs: cs,
              )
            else
              _buildDateInputs(
                dayController: _hijriDayController,
                monthController: _hijriMonthController,
                yearController: _hijriYearController,
                dayHint: l10n.day,
                monthHint: l10n.month,
                yearHint: l10n.year,
                subtitle: l10n.enterHijri,
                cs: cs,
              ),

            const SizedBox(height: 20),

            // 🔹 النتيجة
            if (_conversionResult.isNotEmpty)
              Card(
                color: cs.primary.withOpacity(.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _conversionResult,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // 🔹 الأزرار
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _clearFields,
                      child: Text(l10n.clear, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _convertDate,
                      child: Text(l10n.convert, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 أداة لبناء زر اختيار نوع التحويل
  Widget _buildTypeButton({
    required bool isSelected,
    required String text,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary.withOpacity(.1) : null,
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: colorScheme.primary) : null,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(.8),
          ),
        ),
      ),
    );
  }

  // 🔹 أداة لبناء حقول التاريخ
  Widget _buildDateInputs({
    required TextEditingController dayController,
    required TextEditingController monthController,
    required TextEditingController yearController,
    required String dayHint,
    required String monthHint,
    required String yearHint,
    required String subtitle,
    required ColorScheme cs,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: dayController,
                decoration: InputDecoration(
                  hintText: dayHint,
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: monthController,
                decoration: InputDecoration(
                  hintText: monthHint,
                  prefixIcon: const Icon(Icons.date_range),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: yearController,
                decoration: InputDecoration(
                  hintText: yearHint,
                  prefixIcon: const Icon(Icons.calendar_month),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: TextStyle(color: cs.onSurface.withOpacity(.6)),
        ),
      ],
    );
  }
}
