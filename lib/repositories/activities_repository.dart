import 'package:every_calendar/core/db/abstract_repository.dart';
import 'package:every_calendar/model/activity.dart';

class ActivitiesRepository extends AbstractRepository<Activity> {
  @override
  getEntityInstance() => Activity();

  Future<List<Activity>> getAllWithoutCustomer(
    String uuidCustomer, {
    String actualUuidActivity = '',
  }) async {
    var skipActivities = (await databaseManager.executeRawQuery('''
      SELECT a.uuid AS uuid
      FROM activities a
      LEFT JOIN customers_activities ca ON a.uuid = ca.uuidActivity
      WHERE ca.uuidCustomer = '$uuidCustomer'
      AND ca.deletedAt IS NULL
      ''')).map((e) => e['uuid'] as String).toList();
    var result = await getAll();
    result.removeWhere(
      (r) => skipActivities.contains(r.uuid) && r.uuid != actualUuidActivity,
    );
    return result;
  }
}
