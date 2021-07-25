class TimeRange {
  static const String _zero = '00';
  static const String _maxHours = '08';
  static String _twoDigits(int n) => n.toString().padLeft(2, "0");

  final String hours;
  final String minutes;

  TimeRange._internal({
    required this.hours,
    required this.minutes,
  });

  const TimeRange.zero()
      : hours = _zero,
        minutes = _zero;

  factory TimeRange.minValue() {
    return const TimeRange.zero();
  }

  factory TimeRange.maxValue() {
    return TimeRange._internal(
      hours: _maxHours,
      minutes: _zero,
    );
  }

  factory TimeRange.fromMilliseconds(int milliseconds) {
    var duration = Duration(milliseconds: milliseconds);
    return TimeRange._internal(
      hours: _twoDigits(duration.inHours),
      minutes: _twoDigits(duration.inMinutes.remainder(60)),
    );
  }

  factory TimeRange.fromHoursAndMinutes(int hours, int minutes) {
    return TimeRange._internal(
      hours: _twoDigits(hours),
      minutes: _twoDigits(minutes),
    );
  }

  int get intHours {
    return int.parse(hours);
  }

  int get intMinutes {
    return int.parse(minutes);
  }

  int toMilliseconds() {
    return (intMinutes * 60 * 1000) + (intHours * 60 * 60 * 1000);
  }

  String format() {
    String result = '';
    if (hours != _zero) {
      result += intHours.toString() + 'h ';
    }
    if (minutes != _zero) {
      result += intMinutes.toString() + 'm ';
    }
    if (result.isEmpty) {
      result = '0m';
    }
    return result.trim();
  }
}
