import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedule/main.dart';
import 'package:schedule/models/schedule_event.dart';
import 'package:schedule/services/schedule_service.dart';
import 'package:schedule/settings/language.dart';
import 'package:schedule/widgets/schedule_list_view.dart';
import 'package:schedule/widgets/settings_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

const String _urlKey = 'saved_content_url';
const String _scheduleKey = 'cached_schedule_events';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  final ScheduleService _scheduleService = ScheduleService();

  String _statusMessage = '';
  bool _isLoading = false;
  List<ScheduleEvent> _schedule = [];
  late TabController _tabController;
  Map<DateTime, List<ScheduleEvent>> _scheduleByDay = {};
  List<DateTime> _sortedDays = []; // Теперь это список ВСЕХ дней

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    _loadSavedUrlAndFetch();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // >>> НОВЫЙ МЕТОД ДЛЯ СОХРАНЕНИЯ URL <<<
  Future<void> _saveUrl(String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, url.trim());
  }

  Future<void> _saveSchedule(List<ScheduleEvent> events) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Используем `toJson` из schedule_event.dart
    final List<String> jsonList =
    events.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(_scheduleKey, jsonList);
  }

  Future<void> _loadSchedule() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_scheduleKey);

    if (jsonList != null && jsonList.isNotEmpty) {
      try {
        final events = jsonList
            .map((jsonString) =>
        // Используем `fromJson` из schedule_event.dart
        ScheduleEvent.fromJson(json.decode(jsonString)))
            .toList();
        _updateScheduleAndTabs(events); // Обновляем UI из кэша
        _setStatus(
            getTranslatedString(MyApp.of(context).locale, 'cache_loaded_successfully'));
      } catch (e) {
        _updateScheduleAndTabs([]); // Используем _updateScheduleAndTabs для очистки
        _setStatus('Ошибка загрузки кэша');
      }
    }
  }

  Future<void> _loadSavedUrlAndFetch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedUrl = prefs.getString(_urlKey); // Загружаем сохраненный URL

    if (savedUrl != null && savedUrl.isNotEmpty) {
      _urlController.text = savedUrl;
      // Если есть URL, пробуем загрузить из сети
      await _fetchContent(initialLoad: true);
    } else {
      // Если URL нет, пробуем загрузить кэш (если он есть)
      await _loadSchedule();
    }

    if (_schedule.isEmpty && _urlController.text.isEmpty) {
      _setStatus(getTranslatedString(MyApp.of(context).locale, 'menu_instruction'));
    }
  }

  // >>> ИЗМЕНЕН МЕТОД _fetchContent <<<
  Future<void> _fetchContent({bool initialLoad = false}) async {
    final String userIcalUrl = _urlController.text.trim();
    final locale = MyApp.of(context).locale;

    if (userIcalUrl.isEmpty) {
      if (!initialLoad) {
        _setStatus(getTranslatedString(locale, 'url_input_label'));
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = getTranslatedString(locale, 'loading_data');
    });

    // --- ВАЖНО: Используем URL, который ввел пользователь (это может быть ваш IP) ---
    // Сервис (schedule_service.dart) теперь сам обработает ошибку сертификата.
    final ScheduleResult result =
    await _scheduleService.fetchSchedule(userIcalUrl, locale);
    // ---

    setState(() {
      _isLoading = false;
      if (result.isSuccess && result.events != null) {
        _updateScheduleAndTabs(result.events!); // Обновляем UI
        _saveSchedule(result.events!); // Сохраняем кэш
        _saveUrl(userIcalUrl); // >>> СОХРАНЯЕМ URL ПРИ УСПЕХЕ <<<
        _setStatus(getTranslatedString(locale, 'load_success_message'));
      } else {
        _updateScheduleAndTabs([]); // Очищаем вкладки при ошибке
        _setStatus(result.errorMessage!);
        if (initialLoad) {
          _loadSchedule(); // Попытка загрузить кэш, если первая загрузка не удалась
        }
      }
    });
  }

  // Группировка событий (вспомогательная функция)
  Map<DateTime, List<ScheduleEvent>> _groupByDay(List<ScheduleEvent> events) {
    final Map<DateTime, List<ScheduleEvent>> grouped = {};
    for (var event in events) {
      final date = DateTime(
          event.startTime.year, event.startTime.month, event.startTime.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(event);
    }
    return grouped;
  }

  // >>> НОВАЯ ЛОГИКА ДЛЯ ВКЛАДОК (ВСЕ ДНИ + СЕГОДНЯШНИЙ ДЕНЬ) <<<
  void _updateScheduleAndTabs(List<ScheduleEvent> events) {
    _schedule = events;
    _scheduleByDay = _groupByDay(_schedule);

    _sortedDays = []; // Очищаем старый список

    if (events.isNotEmpty) {
      // 1. Находим диапазон дат
      final allEventDays = _scheduleByDay.keys.toList()..sort();
      final minDate = allEventDays.first;
      final maxDate = allEventDays.last;

      // 2. Генерируем ВСЕ дни в этом диапазоне (включая выходные)
      for (var day = minDate; day.isBefore(maxDate.add(const Duration(days: 1))); day = day.add(const Duration(days: 1))) {
        _sortedDays.add(day);
      }
    }

    // 3. Находим сегодняшний день для initialIndex
    int initialIndex = 0;
    if (_sortedDays.isNotEmpty) {
      final now = DateTime.now();
      final todayNormalized = DateTime(now.year, now.month, now.day);

      // Ищем сегодня
      initialIndex = _sortedDays.indexWhere((day) => day.isAtSameMomentAs(todayNormalized));

      // Если сегодня не найдено (например, сегодня раньше первого дня расписания)
      if (initialIndex == -1) {
        // Ищем следующий ближайший день
        initialIndex = _sortedDays.indexWhere((day) => day.isAfter(todayNormalized));
        // Если и такого нет (расписание в прошлом), ставим 0
        if (initialIndex == -1) {
          initialIndex = 0;
        }
      }
    }

    // 4. Пересоздаем TabController
    _tabController.dispose();
    _tabController = TabController(
        length: _sortedDays.length, // Длина = ВСЕ дни
        vsync: this,
        initialIndex: initialIndex // Устанавливаем на сегодня
    );

    setState(() {}); // Обновляем UI
  }


  void _setStatus(String message) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = MyApp.of(context).locale;
    final languageCode = locale.languageCode;
    // final List<DateTime> sortedDays = _scheduleByDay.keys.toList(); // Старая логика

    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString(locale, 'schedule_title')),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: _schedule.isNotEmpty
            ? TabBar(
          controller: _tabController,
          isScrollable: true,
          // Используем _sortedDays (список ВСЕХ дней)
          tabs: _sortedDays.map((day) {
            return Tab(
              text: DateFormat('EEE, d MMM', languageCode).format(day),
            );
          }).toList(),
        )
            : null,
      ),
      drawer: SettingsDrawer(
        urlController: _urlController,
        onUrlChanged: () => _fetchContent(initialLoad: false),
        isLoading: _isLoading,
      ),
      body: _schedule.isNotEmpty
          ? TabBarView(
        controller: _tabController,
        // Используем _sortedDays (список ВСЕХ дней)
        children: _sortedDays.map((day) {
          // Получаем события ИЛИ пустой список, если дня нет в карте
          final lessons = _scheduleByDay[day] ?? [];
          return ScheduleListView(
            lessons: lessons,
            emptyMessage: getTranslatedString(locale, 'no_lessons_today'),
            languageCode: languageCode,
          );
        }).toList(),
      )
          : Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
              // >>> ДИЗАЙН НЕ ИЗМЕНЕН <<<
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: _schedule.isEmpty
          ? FloatingActionButton.extended(
        onPressed: _isLoading ? null : () => _fetchContent(initialLoad: false),
        label: Text(getTranslatedString(
            locale,
            _urlController.text.isNotEmpty
                ? 'load_schedule_button'
                : 'url_input_label')),
        icon: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Icon(Icons.download),
      )
          : null,
    );
  }
}