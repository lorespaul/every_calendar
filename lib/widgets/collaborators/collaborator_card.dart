import 'package:every_calendar/controllers/loader_controller.dart';
import 'package:every_calendar/core/google/drive_manager.dart';
import 'package:every_calendar/model/collaborator.dart';
import 'package:every_calendar/widgets/collaborators/add_edit_collaborator.dart';
import 'package:every_calendar/widgets/lists/abstract_list_card_delegate.dart';
import 'package:every_calendar/widgets/lists/horizontal_druggable.dart';
import 'package:flutter/material.dart';

class CollaboratorCard extends AbstractListCardDelegate<Collaborator> {
  CollaboratorCard();

  final LoaderController _loaderController = LoaderController();
  final DriveManager _driveManager = DriveManager();

  @override
  Widget build(
    BuildContext context,
    Collaborator entity,
    int index,
    void Function(void Function()) setState,
    Future Function() onDelete,
  ) {
    return HorizontalDruggable(
      underChild: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.all(14),
            child: IconButton(
              onPressed: () async =>
                  await showDeleteDialog(context, entity, onDelete),
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      overChild: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(4),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 30),
                margin: const EdgeInsets.only(left: 10),
                child: Text('${index + 1}'),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 200),
                margin: const EdgeInsets.only(left: 10),
                child: Text(entity.email),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(left: 1),
                child: IconButton(
                  onPressed: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AddEditCollaborator(
                        title: 'Edit Collaborator',
                        collaborator: entity,
                      );
                    })).then((value) => setState(() {}));
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.black45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showDeleteDialog(
    BuildContext context,
    Collaborator collaborator,
    Future Function() onDelete,
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
                      collaborator.name,
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
                    // await _driveManager.denyPermission(collaborator.email);
                    await onDelete();
                    _loaderController.hideLoader();
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
