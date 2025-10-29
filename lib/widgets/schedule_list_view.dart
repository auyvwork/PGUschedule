import 'package:flutter/material.dart';
import 'package:schedule/models/schedule_event.dart';
import 'package:schedule/widgets/schedule_card.dart';

class ScheduleListView extends StatelessWidget {
  final List<ScheduleEvent> lessons;
  final String emptyMessage;
  final String languageCode;

  const ScheduleListView({
    super.key,
    required this.lessons,
    required this.emptyMessage,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      // >>> ДИЗАЙН ВОЗВРАЩЕН К ОРИГИНАЛУ <<<
      // Простое текстовое сообщение без большой иконки
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            // Использование оригинального стиля: titleMedium
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        return ScheduleCard(
          event: lessons[index],
          languageCode: languageCode,
        );
      },
    );
  }
}