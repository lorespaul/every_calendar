import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/model/customer.dart';
import 'package:every_calendar/repositories/customers_repository.dart';
import 'package:every_calendar/widgets/customers/customer_card.dart';
import 'package:every_calendar/widgets/lists/stack_card_wrapper.dart';
import 'package:every_calendar/widgets/lists/base_list.dart';
import 'package:flutter/cupertino.dart';

class CustomersList extends StatelessWidget {
  CustomersList({
    Key? key,
    required this.onSync,
    this.limit = 100,
  }) : super(key: key);

  final Future Function(String, AbstractEntity?) onSync;
  final int limit;
  final CustomersRepository _repository = CustomersRepository();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BaseList<Customer>(
      onSync: onSync,
      repository: _repository,
      limit: limit,
      scrollController: _scrollController,
      buildItem: (ctx, entity, index, length, onDelete) {
        return StackCardWrapper<Customer>(
          child: CustomerCard(
            customer: entity,
            isFirst: index == 0,
            isLast: index == length - 1,
            onSync: onSync,
          ),
          repository: _repository,
          entity: entity,
          index: index,
          onDeleted: onDelete,
          deleteName: entity.name,
        );
      },
    );
  }
}
