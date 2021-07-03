import 'dart:ui';

import 'package:every_calendar/model/collaborator.dart';
import 'package:every_calendar/widgets/scaffold_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddCollaborator extends StatefulWidget {
  const AddCollaborator({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => _AddCollaboratorState();
}

class _AddCollaboratorState extends State<AddCollaborator> {
  final _formKey = GlobalKey<FormState>();
  Collaborator collaborator = Collaborator();

  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: widget.title,
      builder: () {
        return Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 30,
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  // alignment: Alignment.bottomLeft,
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          // borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                      hintText: 'Name *',
                      // isCollapsed: true,
                      // contentPadding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                    ),
                    style: const TextStyle(
                      // fontSize: 30,
                      color: Colors.black,
                      fontFamily: 'RobotoMono',
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                    onChanged: (text) {
                      _nameController
                        ..text = text
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: text.length),
                        );
                      collaborator.name = text;
                    },
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      actionButton: FloatingActionButton(
        onPressed: () {
          _formKey.currentState!.validate();
          // if (_formKey.currentState!.validate()) {
          //   ScaffoldMessenger.of(context)
          //       .showSnackBar(SnackBar(content: Text('Processing Data')));
          // }
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
