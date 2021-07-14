import 'package:intl/intl.dart';

class DateTimeUtils {
  static final DateFormat _shortFormat = DateFormat('dd/MM HH:mm');
  static String formatToShort(DateTime dateTime) {
    return _shortFormat.format(dateTime);
  }

  static DateTime nowUtc() {
    return DateTime.now().toUtc();
  }
}
