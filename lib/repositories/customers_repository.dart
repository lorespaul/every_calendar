import 'package:every_calendar/core/db/abstract_repository.dart';
import 'package:every_calendar/model/customer.dart';

class CustomersRepository extends AbstractRepository<Customer> {
  @override
  getEntityInstance() => Customer();
}
