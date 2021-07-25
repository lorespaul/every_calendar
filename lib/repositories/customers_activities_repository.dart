import 'package:every_calendar/core/db/abstract_repository.dart';
import 'package:every_calendar/model/customer_activity.dart';

class CustomersActivitiesRepository
    extends AbstractRepository<CustomerActivity> {
  @override
  getEntityInstance() => CustomerActivity();
}
