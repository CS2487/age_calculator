import 'package:flutter/material.dart';
import 'package:hijri_date_time/hijri_date_time.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DateConverterScreen extends StatefulWidget {
  const DateConverterScreen({super.key});

  @override
  State<DateConverterScreen> createState() => _DateConverterScreenState();
}

class _DateConverterScreenState extends State<DateConverterScreen> {
  String _conversionType = 'gregorian_to_hijri';

  int? _gDay;
  int? _gMonth;
  int? _gYear;

  int? _hDay;
  int? _hMonth;
  int? _hYear;

  String _conversionResult = '';

  void _convertDate() {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (_conversionType == 'gregorian_to_hijri') {
        if (_gDay == null || _gMonth == null || _gYear == null) {
          throw Exception('invalid date');
        }

        final gregorianDate = DateTime(_gYear!, _gMonth!, _gDay!);
        if (gregorianDate.year != _gYear ||
            gregorianDate.month != _gMonth ||
            gregorianDate.day != _gDay) {
          throw Exception('invalid date');
        }

        final hijriDate = HijriDateTime.fromGregorian(gregorianDate);

        setState(() {
          _conversionResult =
          'التاريخ الهجري: ${hijriDate.day}/${hijriDate.month}/${hijriDate.year} هـ';
          _hDay = hijriDate.day;
          _hMonth = hijriDate.month;
          _hYear = hijriDate.year;
        });
      } else {
        if (_hDay == null || _hMonth == null || _hYear == null) {
          throw Exception('invalid hijri date');
        }

        final hijriDate = HijriDateTime(_hYear!, month: _hMonth!, day: _hDay!);
        if (hijriDate.day != _hDay || hijriDate.month != _hMonth) {
          throw Exception('invalid hijri date');
        }

        final gregorianDate = hijriDate.toGregorian();

        setState(() {
          _conversionResult =
          'التاريخ الميلادي: ${gregorianDate.day}/${gregorianDate.month}/${gregorianDate.year} م';
          _gDay = gregorianDate.day;
          _gMonth = gregorianDate.month;
          _gYear = gregorianDate.year;
        });
      }
    } catch (_) {
      setState(() {
        _conversionResult = l10n.errorInvalidDate;
      });
    }
  }

  void _clearFields() {
    setState(() {
      _gDay = _gMonth = _gYear = null;
      _hDay = _hMonth = _hYear = null;
      _conversionResult = '';
    });
  }

  List<int> _generateYears(int start, int end) =>
      List.generate(end - start + 1, (i) => start + i).reversed.toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final now = DateTime.now();
    final currentGregorianYear = now.year;
    final currentHijriYear = HijriDateTime.now().year;

    final gYears = _generateYears(1900, currentGregorianYear);
    final hYears = _generateYears(1300, currentHijriYear);
    final months = List.generate(12, (i) => i + 1);
    final days = List.generate(31, (i) => i + 1);

    Widget buildDropdown({
      required String label,
      required int? value,
      required List<int> items,
      required ValueChanged<int?> onChanged,
    }) {
      return DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        isExpanded: true,
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? l10n.requiredField : null,
      );
    }

    Widget buildDateSelector({
      required int? day,
      required int? month,
      required int? year,
      required ValueChanged<int?> onDayChanged,
      required ValueChanged<int?> onMonthChanged,
      required ValueChanged<int?> onYearChanged,
      required String subtitle,
      required List<int> yearsList,
    }) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: buildDropdown(
                        label: l10n.day,
                        value: day,
                        items: days,
                        onChanged: onDayChanged),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildDropdown(
                        label: l10n.month,
                        value: month,
                        items: months,
                        onChanged: onMonthChanged),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildDropdown(
                        label: l10n.year,
                        value: year,
                        items: yearsList,
                        onChanged: onYearChanged),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(subtitle,
                  style: TextStyle(color: cs.onSurface.withOpacity(.6))),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            // اختيار نوع التحويل
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

            // حقول الإدخال
            if (_conversionType == 'gregorian_to_hijri')
              buildDateSelector(
                day: _gDay,
                month: _gMonth,
                year: _gYear,
                onDayChanged: (v) => setState(() => _gDay = v),
                onMonthChanged: (v) => setState(() => _gMonth = v),
                onYearChanged: (v) => setState(() => _gYear = v),
                subtitle: l10n.enterGregorian,
                yearsList: gYears,
              )
            else
              buildDateSelector(
                day: _hDay,
                month: _hMonth,
                year: _hYear,
                onDayChanged: (v) => setState(() => _hDay = v),
                onMonthChanged: (v) => setState(() => _hMonth = v),
                onYearChanged: (v) => setState(() => _hYear = v),
                subtitle: l10n.enterHijri,
                yearsList: hYears,
              ),

            const SizedBox(height: 20),

            // النتيجة
            if (_conversionResult.isNotEmpty)
              Card(
                color: cs.primary.withOpacity(.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _conversionResult,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: cs.primary),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // الأزرار
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _clearFields,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.clear, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _convertDate,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
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
}
