import 'package:intl/intl.dart';

class DateTimeUtils {
  static final DateFormat _shortFormat = DateFormat('dd/MM hh:mm');
  static String formatToShort(DateTime dateTime) {
    return _shortFormat.format(dateTime);
  }
}
