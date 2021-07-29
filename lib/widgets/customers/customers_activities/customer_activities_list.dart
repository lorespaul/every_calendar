import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/model/customer.dart';
import 'package:every_calendar/model/customer_activity.dart';
import 'package:every_calendar/repositories/customers_activities_repository.dart';
import 'package:every_calendar/widgets/customers/customers_activities/customer_activity_card.dart';
import 'package:every_calendar/widgets/lists/stack_card_wrapper.dart';
import 'package:every_calendar/widgets/lists/base_list.dart';
import 'package:flutter/cupertino.dart';

class CustomerActivitiesList extends StatelessWidget {
  CustomerActivitiesList({
    Key? key,
    required this.customer,
    required this.onSync,
    this.limit = 100,
  }) : super(key: key);

  final Customer customer;
  final Future Function(String, List<AbstractEntity>) onSync;
  final int limit;
  final CustomersActivitiesRepository _repository =
      CustomersActivitiesRepository();

  @override
  Widget build(BuildContext context) {
    return BaseList<CustomerActivity>(
      onSync: onSync,
      entityInstance: CustomerActivity(),
      repository: _repository,
      limit: limit,
      expand: false,
      getItems: (limit, offset) {
        return _repository.getAllPaginatedByCustomer(
          limit,
          offset,
          customer.uuid,
        );
      },
      buildItem: (ctx, entity, index, length, onDelete) {
        return StackCardWrapper<CustomerActivity>(
          child: CustomerActivityCard(
            customer: customer,
            customerActivity: entity,
            isFirst: index == 0,
            isLast: index == length - 1,
          ),
          repository: _repository,
          entity: entity,
          index: index,
          onDeleted: onDelete,
          deleteName: '', //entity.name,
        );
      },
    );
  }
}
