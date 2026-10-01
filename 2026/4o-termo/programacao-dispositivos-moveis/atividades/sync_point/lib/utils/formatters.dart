import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm:ss');
  static final DateFormat _timeShortFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
  static final DateFormat _dayOfWeekFormat = DateFormat('EEEE, d \'de\' MMMM', 'pt_BR');

  static String formatDate(DateTime dateTime) => _dateFormat.format(dateTime);

  static String formatTime(DateTime dateTime) => _timeFormat.format(dateTime);

  static String formatTimeShort(DateTime dateTime) => _timeShortFormat.format(dateTime);

  static String formatDateTime(DateTime dateTime) => _dateTimeFormat.format(dateTime);

  static String formatDayOfWeek(DateTime dateTime) {
    try {
      return _dayOfWeekFormat.format(dateTime);
    } catch (_) {
      // Fallback if locale data is not loaded
      final days = [
        'Segunda-feira',
        'Terça-feira',
        'Quarta-feira',
        'Quinta-feira',
        'Sexta-feira',
        'Sábado',
        'Domingo'
      ];
      final months = [
        'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
        'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
      ];
      final dayName = days[dateTime.weekday - 1];
      final monthName = months[dateTime.month - 1];
      return '$dayName, ${dateTime.day} de $monthName';
    }
  }

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(1)} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(2)} km';
    }
  }

  static String formatCoordinates(double lat, double lng) {
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }
}
