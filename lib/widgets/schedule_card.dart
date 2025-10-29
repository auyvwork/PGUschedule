import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedule/models/schedule_event.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleEvent event;
  final String languageCode;
  const ScheduleCard(
      {super.key, required this.event, required this.languageCode});

  @override
  Widget build(BuildContext context) {
    final DateFormat timeFormatter = DateFormat('HH:mm', languageCode);
    final String timeRange =
        '${timeFormatter.format(event.startTime)} – ${timeFormatter.format(event.endTime)}';
    final String date = DateFormat('EEE, d MMM', languageCode).format(event.startTime);

    return Card(
      color: Theme.of(context).colorScheme.surface ,
      elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(50),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeRange,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),

              ],
            ),

               Text(

                event.summary,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 10),
            _buildCompactInfoRow(
              context,
              Icons.calendar_today_outlined,
              date,
            ),
            const SizedBox(height: 6),
            if (event.location.isNotEmpty)
              _buildCompactInfoRow(
                context,
                Icons.location_on_outlined,
                event.location,
              ),
            if (event.location.isNotEmpty) const SizedBox(height: 6),
            if (event.description.isNotEmpty)
              _buildCompactInfoRow(
                context,
                Icons.person_outline,
                event.description,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInfoRow(BuildContext context, IconData icon, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.isEmpty ? 'Не указано' : value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: valueColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}