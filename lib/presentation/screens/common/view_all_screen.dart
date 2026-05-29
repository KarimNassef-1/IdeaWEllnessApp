import 'package:flutter/material.dart';

import '../../../core/utils/showcase_ai_images.dart';
import '../../../domain/entities/gym_session.dart';
import '../../widgets/app_image.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({
    super.key,
    required this.title,
    required this.items,
    this.mode,
    this.sessions = const [],
  });

  final String title;
  final List<String> items;
  final String? mode;
  final List<GymSession> sessions;

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.mode == 'classes') {
      _selectedDate = _normalizeDate(DateTime.now());
    }
  }

  DateTime _normalizeDate(DateTime value) => DateTime(value.year, value.month, value.day);

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<DateTime> _timelineDates({int days = 7}) {
    final start = _normalizeDate(DateTime.now());
    return List.generate(days, (index) => start.add(Duration(days: index)));
  }

  String _weekdayName(int weekday) {
    const names = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return names[(weekday - 1).clamp(0, 6)];
  }

  String _formattedDate(DateTime date) {
    return date.day.toString();
  }

  List<GymSession> _sessionsForDay(String weekdayShort, DateTime selectedDate) {
    const fullToShort = {
      'Monday': 'Mon',
      'Tuesday': 'Tue',
      'Wednesday': 'Wed',
      'Thursday': 'Thu',
      'Friday': 'Fri',
      'Saturday': 'Sat',
      'Sunday': 'Sun',
    };
    final selectedIsToday = _isSameDate(
      _normalizeDate(selectedDate),
      _normalizeDate(DateTime.now()),
    );

    return widget.sessions.where((session) {
      final day = (session.day ?? '').trim();
      if (day.isEmpty) return selectedIsToday;

      final short = fullToShort[day] ?? day;
      return short.toLowerCase() == weekdayShort.toLowerCase();
    }).toList();
  }

  Map<String, List<GymSession>> _sessionsGroupedByTime(List<GymSession> sessions) {
    final grouped = <String, List<GymSession>>{};
    for (final session in sessions) {
      grouped.putIfAbsent(session.timeStart, () => <GymSession>[]).add(session);
    }

    final keys = grouped.keys.toList()
      ..sort((a, b) => _timeToMinutes(a).compareTo(_timeToMinutes(b)));
    return {for (final key in keys) key: grouped[key]!};
  }

  String _levelLabel(GymSession session) {
    return _isLadiesOnly(session) ? 'Ladies Only' : 'All Levels';
  }

  Widget _classShowcaseCard(GymSession session) {
    final imageUrl = showcaseAiImage(
      'high action gym class ${session.name} coached by ${session.trainer} premium cinematic',
      seed: session.id.hashCode.abs() % 100000,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 190,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(source: imageUrl, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000000)],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HELIOPOLIS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    session.name.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.trainer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFE6E6E6),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0x66000000),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0x33FFFFFF)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule_rounded, size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${session.timeStart} to ${session.timeEnd}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0x66A0A0A0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _levelLabel(session),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _timeToMinutes(String value) {
    final parts = value.trim().split(' ');
    if (parts.length != 2) return 0;
    final hm = parts.first.split(':');
    if (hm.length != 2) return 0;

    final hourRaw = int.tryParse(hm.first) ?? 0;
    final minute = int.tryParse(hm.last) ?? 0;
    final period = parts.last.toUpperCase();

    var hour = hourRaw % 12;
    if (period == 'PM') hour += 12;
    return (hour * 60) + minute;
  }

  bool _isLadiesOnly(GymSession session) {
    return session.name.toLowerCase().contains('ladies only');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == 'classes') {
      final timelineDates = _timelineDates();
      final selectedDate = _selectedDate ?? timelineDates.first;
      final selectedDayName = _weekdayName(selectedDate.weekday);
      final daySessions = _sessionsForDay(selectedDayName, selectedDate);
      final groupedByTime = _sessionsGroupedByTime(daySessions);

      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: const Text(
                  'Pilates and Kickboxing are included in all packages. Cellulite Control is a paid program, except on Thursdays for members.',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(
              height: 78,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final dateValue = timelineDates[index];
                  final day = _weekdayName(dateValue.weekday);
                  final selected = _isSameDate(dateValue, selectedDate);
                  final today = _normalizeDate(DateTime.now());
                  final isToday = _isSameDate(dateValue, today);
                  final selectedIsToday = _isSameDate(selectedDate, today);
                  final date = _formattedDate(dateValue);
                  const borderColor = Color(0xFFD9D9D9);
                  const chipColor = Color(0xFFEDEDED);
                  final dayNameColor = selected ? const Color(0xFFFF8A3D) : const Color(0xFF8F8F8F);
                  final dayNumberColor = selected ? const Color(0xFFFF8A3D) : Colors.black;
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _selectedDate = dateValue),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      constraints: const BoxConstraints(minWidth: 62),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 1.6),
                        color: chipColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                              color: dayNameColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                              color: dayNumberColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 6,
                            child: Center(
                              child: isToday && !selectedIsToday
                                  ? Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF8A3D),
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemCount: timelineDates.length,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final timeKey = groupedByTime.keys.elementAt(index);
                  final slotSessions = groupedByTime[timeKey] ?? const <GymSession>[];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeKey,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...slotSessions.map((session) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _classShowcaseCard(session),
                        );
                      }),
                    ],
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemCount: groupedByTime.length,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Text(widget.items[index]),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: widget.items.length,
      ),
    );
  }
}
