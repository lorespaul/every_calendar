import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/model/activity.dart';
import 'package:every_calendar/repositories/activities_repository.dart';
import 'package:every_calendar/widgets/activities/activity_card.dart';
import 'package:every_calendar/widgets/lists/stack_card_wrapper.dart';
import 'package:every_calendar/widgets/lists/base_list.dart';
import 'package:flutter/cupertino.dart';

class ActivitiesList extends StatelessWidget {
  ActivitiesList({
    Key? key,
    required this.onSync,
    this.limit = 100,
  }) : super(key: key);

  final Future Function(String, AbstractEntity?) onSync;
  final int limit;
  final ActivitiesRepository _repository = ActivitiesRepository();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BaseList<Activity>(
      onSync: onSync,
      repository: _repository,
      limit: limit,
      scrollController: _scrollController,
      buildItem: (ctx, entity, index, length, onDelete) {
        return StackCardWrapper<Activity>(
          child: ActivityCard(
            activity: entity,
            isFirst: index == 0,
            isLast: index == length - 1,
          ),
          repository: _repository,
          entity: entity,
          index: index,
          onBeforeDelete: () async {
            // await _driveManager.denyPermission(collaborator.email);
          },
          onDeleted: onDelete,
          deleteName: entity.name,
        );
      },
    );
  }
}
