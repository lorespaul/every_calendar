import 'package:every_calendar/core/db/abstract_repository.dart';
import 'package:every_calendar/model/activity.dart';

class ActivitiesRepository extends AbstractRepository<Activity> {
  @override
  getEntityInstance() => Activity();
}
