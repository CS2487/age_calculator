import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri_date_time/hijri_date_time.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AgeResultScreen extends StatefulWidget {
  final Map<String, dynamic> ageDetails;
  final Map<String, dynamic> nextBirthdayInfo;
  final DateTime birthDate;
  final HijriDateTime? hijriBirthDate;
  final String calendarType;

  const AgeResultScreen({
    super.key,
    required this.ageDetails,
    required this.nextBirthdayInfo,
    required this.birthDate,
    this.hijriBirthDate,
    required this.calendarType,
  });

  @override
  State<AgeResultScreen> createState() => _AgeResultScreenState();
}

class _AgeResultScreenState extends State<AgeResultScreen> {
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
    final l10n = AppLocalizations.of(context)!;
    final years = widget.ageDetails['years'];
    final months = widget.ageDetails['months'];
    final days = widget.ageDetails['days'];

    final String shareText = l10n.shareResultBody(years, months, days);
    Share.share(shareText, subject: l10n.shareResultSubject);
  }

  String _getHijriDayName(HijriDateTime hijriDate, String locale) {
    final gregorianDate = hijriDate.toGregorian();
    return intl.DateFormat('EEEE', locale).format(gregorianDate);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ageResultTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareResult,
            tooltip: l10n.shareResultTooltip,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            _ageHeroCard(cs, l10n),
            const SizedBox(height: 16),
            _birthDateDetails(cs, l10n),
            const SizedBox(height: 16),
            _statsGrid(cs, l10n),
            const SizedBox(height: 16),
            _nextBirthdayCard(cs, l10n),
          ],
        ),
      ),
    );
  }

  // ------------------------
  // Inner Widgets
  // ------------------------

  Widget _ageHeroCard(ColorScheme cs, AppLocalizations l10n) {
    final age = widget.ageDetails;
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.hourglass_bottom_rounded, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Text(l10n.yourCurrentAge,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l10n.ageSummary(
                age['years'], age['months'], age['days']),
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }

  Widget _birthDateDetails(ColorScheme cs, AppLocalizations l10n) {
    final locale = l10n.localeName;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.birthDateDetails,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(l10n.gregorian,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: cs.primary)),
                    Text(intl.DateFormat.yMd(locale).format(widget.birthDate)),
                    Text(intl.DateFormat('EEEE', locale)
                        .format(widget.birthDate)),
                  ],
                ),
                Column(
                  children: [
                    Text(l10n.hijri,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: cs.primary)),
                    if (widget.hijriBirthDate != null) ...[
                      Text(
                          '${widget.hijriBirthDate!.year}/${widget.hijriBirthDate!.month}/${widget.hijriBirthDate!.day}'),
                      Text(_getHijriDayName(widget.hijriBirthDate!, locale)),
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
    );
  }

  Widget _statsGrid(ColorScheme cs, AppLocalizations l10n) {
    final age = widget.ageDetails;
    final items = [
      (l10n.totalMonths, Icons.calendar_view_month_rounded,
      age['totalMonths'].toString()),
      (l10n.totalDays, Icons.today_rounded, age['totalDays'].toString()),
      (l10n.totalHours, Icons.access_time_rounded,
      age['totalHours'].toString()),
      (l10n.totalMinutes, Icons.timer_rounded,
      age['totalMinutes'].toString()),
      (l10n.totalSeconds, Icons.timelapse_rounded,
      age['totalSeconds'].toString()),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(builder: (context, c) {
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
              return _statTile(title, icon, value, cs);
            },
          );
        }),
      ),
    );
  }

  Widget _statTile(String title, IconData icon, String value, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(.2)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      ),
    );
  }

  Widget _nextBirthdayCard(ColorScheme cs, AppLocalizations l10n) {
    final locale = l10n.localeName;
    final birthDayName = intl.DateFormat('EEEE', locale).format(widget.birthDate);
    final nextBirthdayName = intl.DateFormat('EEEE', locale)
        .format(widget.nextBirthdayInfo['date']);
    final nextBirthdayDate = intl.DateFormat.yMMMMd(locale)
        .format(widget.nextBirthdayInfo['date']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: cs.primary.withOpacity(.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.event_available_outlined, color: cs.primary),
              ),
              const SizedBox(width: 10),
              Text(l10n.nextBirthday,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.youWereBornOn(birthDayName),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(l10n.yourNextBirthdayWillBeOn(nextBirthdayName)),
          const SizedBox(height: 6),
          Text(l10n.dateLabel(nextBirthdayDate)),
          const SizedBox(height: 12),
          _countdownStrip(cs, l10n),
        ]),
      ),
    );
  }

  Widget _countdownStrip(ColorScheme cs, AppLocalizations l10n) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

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
          _timeBox(l10n.days, days),
          const Text(':',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _timeBox(l10n.hours, hours),
          const Text(':',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _timeBox(l10n.minutes, minutes),
          const Text(':',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _timeBox(l10n.seconds, seconds),
        ],
      ),
    );
  }

  Widget _timeBox(String label, int value) {
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

