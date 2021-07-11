import 'package:every_calendar/controllers/loader_controller.dart';
import 'package:every_calendar/core/google/drive_manager.dart';
import 'package:every_calendar/model/collaborator.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
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
      maxSwipe: 70,
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
        margin: EdgeInsets.only(
          top: index == 0 ? 4 : 0,
          right: 4,
          bottom: 4,
          left: 4,
        ),
        child: InkWell(
          onTap: () async {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AddEditCollaborator(
                title: 'Edit Collaborator',
                collaborator: entity,
              );
            })).then((value) => setState(() {}));
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.black26,
                  ),
                  margin: const EdgeInsets.only(left: 10),
                  alignment: Alignment.center,
                  child: Text(
                    entity.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 25),
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entity.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: Text(
                          entity.email,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.only(right: 20),
                  child: Text(
                    DateTimeUtils.formatToShort(entity.modifiedAt),
                    style: const TextStyle(fontSize: 11),
                  ),
                )
              ],
            ),
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
