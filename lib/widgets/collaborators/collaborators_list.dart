import 'package:every_calendar/core/db/abstract_entity.dart';
// import 'package:every_calendar/core/google/drive_manager.dart';
import 'package:every_calendar/model/collaborator.dart';
import 'package:every_calendar/repositories/collaborators_repository.dart';
import 'package:every_calendar/widgets/collaborators/collaborator_card.dart';
import 'package:every_calendar/widgets/lists/stack_card_wrapper.dart';
import 'package:every_calendar/widgets/lists/base_list.dart';
import 'package:flutter/cupertino.dart';

class CollaboratorsList extends StatelessWidget {
  CollaboratorsList({
    Key? key,
    required this.onSync,
    this.limit = 100,
  }) : super(key: key);

  final Future Function(String, AbstractEntity?) onSync;
  final int limit;
  final CollaboratorsRepository _repository = CollaboratorsRepository();
  final ScrollController _scrollController = ScrollController();
  // final DriveManager _driveManager = DriveManager();

  @override
  Widget build(BuildContext context) {
    return BaseList<Collaborator>(
      onSync: onSync,
      repository: _repository,
      limit: limit,
      scrollController: _scrollController,
      buildItem: (ctx, entity, index, length, onDelete) {
        return StackCardWrapper<Collaborator>(
          child: CollaboratorCard(
            collaborator: entity,
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
