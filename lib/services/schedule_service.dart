import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:schedule/models/schedule_event.dart';
import 'package:schedule/services/ical_parser.dart';
import 'package:schedule/settings/language.dart';

class ScheduleResult {
  final List<ScheduleEvent>? events;
  final String? errorMessage;

  ScheduleResult.success(this.events) : errorMessage = null;
  ScheduleResult.error(this.errorMessage) : events = null;

  bool get isSuccess => events != null;
}

class ScheduleService {
  ScheduleService();

  Future<ScheduleResult> fetchSchedule(String urlString, Locale locale) async {
    // --- ИЗМЕНЕНИЕ: Убрана строгая проверка на 'https://' для работы с прокси-сервером.
    // if (!urlString.startsWith('https://')) {
    //   return ScheduleResult.error(
    //       '${getTranslatedString(locale, 'error_loading_title')}: URL должен начинаться с https://.');
    // }
    // --- КОНЕЦ ИЗМЕНЕНИЯ

    final client = http.Client();
    try {
      final uri = Uri.parse(urlString);
      final response =
      await client.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        try {
          if (response.body.trim().isEmpty) {
            return ScheduleResult.error(
              getTranslatedString(locale, 'no_schedule_title'),
            );
          }

          final events = parseIcalData(response.body);

          if (events.isNotEmpty) {
            return ScheduleResult.success(events);
          } else {
            return ScheduleResult.error(
              '${getTranslatedString(locale, 'no_schedule_title')}\n${getTranslatedString(locale, 'no_schedule_body')}',
            );
          }
        } catch (e) {
          return ScheduleResult.error(
              '${getTranslatedString(locale, 'error_loading_title')}: Ошибка парсинга данных.');
        }
      } else {
        return ScheduleResult.error(
            '${getTranslatedString(locale, 'error_loading_title')}. Статус код: ${response.statusCode}.');
      }
    } on SocketException {
      return ScheduleResult.error(
          '${getTranslatedString(locale, 'error_loading_title')}: Ошибка сети.');
    } on FormatException {
      return ScheduleResult.error(
          '${getTranslatedString(locale, 'error_loading_title')}: Некорректный формат URL.');
    } on TimeoutException {
      return ScheduleResult.error(
          '${getTranslatedString(locale, 'error_loading_title')}: Сервер не отвечает (Таймаут).');
    } catch (e) {
      return ScheduleResult.error(
          '${getTranslatedString(locale, 'error_loading_title')}: Неизвестная ошибка: $e');
    }
  }
}