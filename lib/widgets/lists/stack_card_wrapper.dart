import 'package:every_calendar/controllers/loader_controller.dart';
import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/db/abstract_repository.dart';
import 'package:every_calendar/widgets/lists/horizontal_druggable.dart';
import 'package:flutter/material.dart';

class StackCardWrapper<T extends AbstractEntity> extends StatefulWidget {
  const StackCardWrapper({
    Key? key,
    required this.child,
    required this.repository,
    required this.entity,
    required this.index,
    this.onBeforeDelete,
    required this.onDeleted,
    required this.deleteName,
  }) : super(key: key);

  final Widget child;
  final AbstractRepository<T> repository;
  final T entity;
  final int index;
  final Future Function()? onBeforeDelete;
  final Function() onDeleted;
  final String deleteName;

  @override
  State<StatefulWidget> createState() => _StackCardStateWrapper<T>();
}

class _StackCardStateWrapper<T extends AbstractEntity>
    extends State<StackCardWrapper<T>> {
  final LoaderController _loaderController = LoaderController();
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HorizontalDruggable(
      maxSwipe: 70,
      onDismiss: _isDismissing
          ? () {
              _isDismissing = false;
              widget.onDeleted();
            }
          : null,
      underChild: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.all(14),
            child: IconButton(
              onPressed: () async => await showDeleteDialog(
                context,
                widget.entity,
              ),
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      overChild: widget.child,
    );
  }

  Future<void> showDeleteDialog(
    BuildContext context,
    T entity,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext _) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Delete collaborator'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Are you shure to delete'),
                  ],
                ),
                Container(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.deleteName,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const Spacer(flex: 3),
                TextButton(
                  child: const Text(
                    'DELETE',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _loaderController.showLoader(context);
                    await widget.onBeforeDelete?.call();
                    await widget.repository.delete(entity);
                    _loaderController.hideLoader();
                    _isDismissing = true;
                    setState(() {});
                  },
                ),
                const Spacer(),
              ],
            ),
          ],
        );
      },
    );
  }
}
