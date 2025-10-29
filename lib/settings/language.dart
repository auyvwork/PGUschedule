import 'package:flutter/material.dart';

Map<String, Map<String, String>> localizedStrings = {
  'ru': {
    'schedule_title': 'Расписание ПГНИУ',
    'settings': 'Настройки',
    'theme': 'Светлая/Темная тема',
    'language': 'Язык',
    'about': 'О приложении',
    'support_text': 'Поддержите разработку! На чашку кофе или на новые функции.',
    'ru_name': 'Русский',
    'en_name': 'English',
    'theme_light': 'Светлая',
    'theme_dark': 'Темная',
    'theme_system': 'Системная', // Добавлено
    'menu_instruction': 'Нажмите иконку меню для вызова настроек.',
    'about_title': 'Расписание ПГНИУ',
    'about_body_p1': 'Неофициальное приложение для удобного доступа к расписанию занятий Пермского государственного национального исследовательского университета.',
    'about_body_p2': 'Быстро смотрите свое расписание, меняйте темы и язык интерфейса. Разработано студентом для студентов.',
    'about_version': 'Версия 1.0.0',
    'support_card': 'Карта: 2202 2082 6030 2469',
    'load_schedule_button': 'Загрузить расписание',
    'load_schedule': 'Загрузить',
    'reset_url_button': 'Изменить URL',
    'clear_url_button': 'Очистить URL',
    'no_schedule_title': 'Расписание на неделю не найдено.',
    'no_schedule_body': 'Проверьте, что ссылка корректна и расписание содержит события.',
    'url_input_label': 'URL расписания (iCal)',
    'error_loading_title': 'Ошибка загрузки расписания',
    'today_tab': 'Сегодня',
    'no_lessons_today': 'На этот день занятий нет.', // ИЗМЕНЕНО
    'loading_data': 'Загрузка данных...',
    'offline_mode_active': 'Отображается кэшированное расписание.',
    'load_success_message': 'Расписание загружено',
    'no_internet_connection': 'Нет подключения к интернету',
    'using_cached_data': 'Используются кэшированные данные',
    'cache_loaded_successfully': 'Кэшированное расписание загружено',
  },
  'en': {
    'schedule_title': 'PSU Schedule App',
    'settings': 'Settings',
    'theme': 'Light/Dark Theme',
    'language': 'Language',
    'about': 'About',
    'support_text': 'Support the development! For a cup of coffee or new features.',
    'ru_name': 'Русский',
    'en_name': 'English',
    'theme_light': 'Light',
    'theme_dark': 'Dark',
    'theme_system': 'System', // Добавлено
    'menu_instruction': 'Tap the menu icon to open settings.',
    'about_title': 'PSU Schedule App',
    'about_body_p1': 'An unofficial application for convenient access to the class schedule of Perm State University (PSU).',
    'about_body_p2': 'Quickly check your schedule, switch themes and interface language. Developed by a student for students.',
    'about_version': 'Version 1.0.0',
    'support_card': 'Card: 2202 2082 6030 2469',
    'load_schedule_button': 'Load Schedule',
    'load_schedule': 'Load',
    'reset_url_button': 'Change URL',
    'clear_url_button': 'Clear URL',
    'no_schedule_title': 'Schedule for the week not found.',
    'no_schedule_body': 'Check that the link is correct and the schedule contains events.',
    'url_input_label': 'Schedule URL (iCal)',
    'error_loading_title': 'Schedule Loading Error',
    'today_tab': 'Today',
    'no_lessons_today': 'No lessons for this day.', // ИЗМЕНЕНО
    'loading_data': 'Loading data...',
    'offline_mode_active': 'Displayed cached schedule.',
    'load_success_message': 'Schedule loaded',
    'no_internet_connection': 'No internet connection',
    'using_cached_data': 'Using cached data',
    'cache_loaded_successfully': 'Cached schedule loaded',
  },
};

String getTranslatedString(Locale locale, String key) {
  return localizedStrings[locale.languageCode]?[key] ??
      localizedStrings['ru']![key] ??
      key;
}