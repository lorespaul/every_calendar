class CalendarService {
  static final CalendarService _calendarService = CalendarService._internal();

  factory CalendarService() => _calendarService;

  CalendarService._internal();
}
