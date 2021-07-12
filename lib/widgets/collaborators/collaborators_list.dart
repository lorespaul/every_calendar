import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/model/collaborator.dart';
import 'package:every_calendar/repositories/collaborators_repository.dart';
import 'package:every_calendar/widgets/collaborators/collaborator_card.dart';
import 'package:every_calendar/widgets/lists/base_list.dart';
import 'package:flutter/cupertino.dart';

class CollaboratorsList extends StatefulWidget {
  const CollaboratorsList({
    Key? key,
    required this.onSync,
    this.limit = 10,
  }) : super(key: key);

  final Function(String, AbstractEntity?) onSync;
  final int limit;

  @override
  State<StatefulWidget> createState() => _CollaboratorsListState();
}

enum CollaboratorItemAction { remove, removing }

class _CollaboratorsListState extends State<CollaboratorsList>
    with SingleTickerProviderStateMixin {
  final CollaboratorsRepository _repository = CollaboratorsRepository();
  final Map<int, CollaboratorItemAction> _actionsByIndex = {};
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseList<Collaborator>(
      onSync: widget.onSync,
      repository: _repository,
      limit: widget.limit,
      buildItem: (ctx, entity, index, onDelete) {
        var card = CollaboratorCard(
          entity: entity,
          index: index,
          onDelete: () {
            _actionsByIndex[index] = CollaboratorItemAction.remove;
            setState(() {});
          },
          onDropped: _actionsByIndex[index] == CollaboratorItemAction.remove
              ? (height) => _closeItem(index, height, onDelete)
              : null,
        );
        if (_actionsByIndex[index] == CollaboratorItemAction.removing) {
          return SizedBox(
            height: _animation.value,
            width: MediaQuery.of(context).size.width,
          );
        }
        return card;
      },
    );
  }

  void _closeItem(int index, double height, Function() onDelete) {
    _actionsByIndex[index] = CollaboratorItemAction.removing;
    _controller.duration = Duration(milliseconds: height.ceil());
    _animation = Tween<double>(
      begin: 100,
      end: 0,
    ).animate(_controller);
    _animation.addListener(
      () => setState(() {}),
    );
    _controller.reset();
    _controller.forward().then((value) {
      _actionsByIndex.remove(index);
      onDelete();
    });
  }
}
