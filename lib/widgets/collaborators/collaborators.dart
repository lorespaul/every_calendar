import 'package:every_calendar/constants/all_constants.dart';
import 'package:every_calendar/constants/dimensions.dart';
import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/db/base_repository.dart';
import 'package:every_calendar/model/collaborator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'add_edit_collaborator.dart';

class Collaborators extends StatefulWidget {
  const Collaborators({Key? key, required this.onSync}) : super(key: key);

  final Function(String, AbstractEntity?) onSync;

  @override
  State<StatefulWidget> createState() => _CollaboratorsState();
}

class _CollaboratorsState extends State<Collaborators> {
  final _collaboratorsRepository = BaseRepository<Collaborator>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Collaborator>>(
      future: getCollaborators(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            height: MediaQuery.of(context).size.height -
                Dimensions.scaffoldTopAndBottomBarHeight,
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  final c = snapshot.data![index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: Text(c.name),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: Text(c.email),
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
                                    collaborator: c,
                                  );
                                })).then((value) => setState(() {}));
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 1),
                            child: IconButton(
                              onPressed: () async => await showDeleteDialog(c),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const Text('Error');
        }
        return const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        );
      },
    );
  }

  Future<List<Collaborator>> getCollaborators() {
    return _collaboratorsRepository.getAll(Collaborator());
  }

  Future<void> _onRefresh() async {
    await widget.onSync(AllConstants.currentContext, Collaborator());
    setState(() {});
  }

  Future<void> showDeleteDialog(Collaborator collaborator) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
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
                TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'DELETE',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    await _collaboratorsRepository.delete(collaborator);
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
