import 'dart:developer' as developer;
import 'package:schedule/models/schedule_event.dart';

List<ScheduleEvent> parseIcalData(String icalContent) {
  final List<ScheduleEvent> events = [];
  final cleanedContent = icalContent.replaceAll('\r', '');
  final eventBlocks = cleanedContent.split(RegExp(r'BEGIN:VEVENT'));

  for (var i = 1; i < eventBlocks.length; i++) {
    final block = eventBlocks[i];

    String summary = 'Название не указано';
    String description = 'Преподаватель не указан';
    String location = 'Место не указано';
    String status = 'Статус не указан';
    DateTime? dtStart;
    DateTime? dtEnd;

    String? getValue(String key) {
      final regex = RegExp('^$key(;[^:]*)*:(.*)', caseSensitive: false, multiLine: true);
      final match = regex.firstMatch(block);
      if (match != null && match.group(2) != null) {
        return match
            .group(2)
            ?.trim()
            .replaceAll('\\n', ' ')
            .replaceAll(r'\,', ',');
      }
      return null;
    }

    DateTime? parseIcalDateTime(String? dtString) {
      if (dtString == null || dtString.isEmpty) return null;

      if (dtString.contains(':')) {
        dtString = dtString.split(':').last;
      }

      if (dtString.length < 15) return null;

      try {
        final date = dtString.substring(0, 8);
        final time = dtString.substring(9, 15);
        final isoString =
            '${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)}T'
            '${time.substring(0, 2)}:${time.substring(2, 4)}:${time.substring(4, 6)}';

        if (dtString.endsWith('Z')) {
          return DateTime.parse('${isoString}Z').toLocal();
        } else {
          return DateTime.parse(isoString);
        }
      } catch (e) {
        developer.log('Ошибка парсинга времени iCal: $dtString | $e');
        return null;
      }
    }

    summary = getValue('SUMMARY') ?? summary;
    description = getValue('DESCRIPTION') ?? description;
    location = getValue('LOCATION') ?? location;
    status = getValue('STATUS') ?? status;

    dtStart = parseIcalDateTime(getValue('DTSTART'));
    dtEnd = parseIcalDateTime(getValue('DTEND'));

    if (dtStart != null && dtEnd != null) {
      events.add(
        ScheduleEvent(
          summary: summary,
          description: description,
          startTime: dtStart,
          endTime: dtEnd,
          location: location,
          status: status,
        ),
      );
    }
  }

  return events;
}