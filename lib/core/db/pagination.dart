import 'package:every_calendar/core/db/abstract_entity.dart';

class Pagination<T extends AbstractEntity> {
  List<T> result;
  int limit;
  int offset;
  int count;
  late bool hasNext;

  Pagination({
    required this.result,
    required this.limit,
    required this.offset,
    required this.count,
  }) {
    hasNext = offset + limit < count;
  }
}
