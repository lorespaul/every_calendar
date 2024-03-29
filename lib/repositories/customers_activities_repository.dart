import 'package:every_calendar/core/db/abstract_repository.dart';
import 'package:every_calendar/core/db/pagination.dart';
import 'package:every_calendar/model/customer_activity.dart';

class CustomersActivitiesRepository
    extends AbstractRepository<CustomerActivity> {
  @override
  getEntityInstance() => CustomerActivity();

  Future<Pagination<CustomerActivity>> getAllPaginatedByCustomer(
    int limit,
    int offset,
    String uuidCustomer,
  ) async {
    return await getAllPaginatedFiltered(
      limit,
      offset,
      where: 'uuidCustomer = ?',
      whereArgs: [uuidCustomer],
    );
  }

  Future<int> logicalDeleteByActivityUuid(String uuidActivity) async {
    var e = getEntityInstance();
    return await databaseManager.logicalDelete(
      e.getTableName(),
      'uuidActivity = ?',
      [uuidActivity],
    );
  }

  Future<int> logicalDeleteByCustomerUuid(String uuidCustomer) async {
    var e = getEntityInstance();
    return await databaseManager.logicalDelete(
      e.getTableName(),
      'uuidCustomer = ?',
      [uuidCustomer],
    );
  }
}
