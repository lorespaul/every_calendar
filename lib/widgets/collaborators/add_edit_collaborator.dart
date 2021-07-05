import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:every_calendar/core/db/base_repository.dart';
import 'package:every_calendar/model/collaborator.dart';
import 'package:every_calendar/services/login_service.dart';
import 'package:every_calendar/widgets/scaffold_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class AddEditCollaborator extends StatefulWidget {
  const AddEditCollaborator({
    Key? key,
    required this.title,
    this.collaborator,
  }) : super(key: key);

  final String title;
  final Collaborator? collaborator;

  @override
  State<StatefulWidget> createState() => _AddEditCollaboratorState();
}

class _AddEditCollaboratorState extends State<AddEditCollaborator> {
  final _formKey = GlobalKey<FormState>();
  final LoginService _loginService = LoginService();
  final _textFieldStyle = const TextStyle(
    // fontSize: 30,
    color: Colors.black,
    fontFamily: 'RobotoMono',
    fontFeatures: [FontFeature.tabularFigures()],
  );
  final _collaboratorsRepository = BaseRepository<Collaborator>();
  Collaborator? collaborator;
  bool isAdd = true;

  @override
  void initState() {
    super.initState();
    isAdd = widget.collaborator == null;
    collaborator = widget.collaborator ?? Collaborator();
  }

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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Name *',
                      // isCollapsed: true,
                      // contentPadding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                    ),
                    style: _textFieldStyle,
                    initialValue: collaborator?.name,
                    onChanged: (text) {
                      collaborator!.name = text;
                    },
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 30,
                  margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                  // alignment: Alignment.bottomLeft,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Email *',
                      // isCollapsed: true,
                      // contentPadding: EdgeInsets.fromLTRB(5, 2, 5, 2),
                    ),
                    style: _textFieldStyle,
                    initialValue: collaborator?.email,
                    onChanged: (text) {
                      collaborator!.email = text;
                    },
                    validator: (text) {
                      if (text == null ||
                          text.isEmpty ||
                          !EmailValidator.validate(text)) {
                        return 'Please enter email';
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
          if (_formKey.currentState!.validate()) {
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              var now = DateTime.now();
              if (isAdd) {
                collaborator!.createdAt = now;
                collaborator!.createdBy = _loginService.loggedUser.email;
              }
              collaborator!.modifiedAt = now;
              collaborator!.modifiedBy = _loginService.loggedUser.email;

              _collaboratorsRepository.insertOrUpdate(collaborator!).then((c) {
                developer.log('collaborator: ' + collaboratorToJson(c!));
                Navigator.of(context).pop();
              });
            });
          }
        },
        child: isAdd ? const Icon(Icons.add) : const Icon(Icons.save_alt),
        backgroundColor: Colors.green,
      ),
    );
  }
}
