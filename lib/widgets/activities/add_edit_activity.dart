import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:every_calendar/core/google/people_service.dart';
import 'package:every_calendar/model/collaborator.dart';
import 'package:every_calendar/controllers/loader_controller.dart';
import 'package:every_calendar/core/google/login_service.dart';
import 'package:every_calendar/repositories/collaborators_repository.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
import 'package:every_calendar/widgets/scaffold_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class AddEditActivity extends StatefulWidget {
  const AddEditActivity({
    Key? key,
    required this.title,
    this.collaborator,
  }) : super(key: key);

  final String title;
  final Collaborator? collaborator;

  @override
  State<StatefulWidget> createState() => _AddEditActivityState();
}

class _AddEditActivityState extends State<AddEditActivity> {
  final _formKey = GlobalKey<FormState>();
  final LoaderController _loaderController = LoaderController();
  final LoginService _loginService = LoginService();
  final PeopleService _peopleService = PeopleService();
  final _textFieldStyle = const TextStyle(
    color: Colors.black,
    fontFamily: 'RobotoMono',
    fontFeatures: [FontFeature.tabularFigures()],
  );
  final _collaboratorsRepository = CollaboratorsRepository();
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
    return WillPopScope(
      onWillPop: () {
        FocusScope.of(context).requestFocus(FocusNode());
        return Future.delayed(const Duration(milliseconds: 100), () => true);
      },
      child: ScaffoldWrapper(
        title: widget.title,
        builder: (ctx) {
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
                      keyboardType: TextInputType.emailAddress,
                      initialValue: collaborator?.email,
                      onChanged: (text) async {
                        collaborator!.email = text;
                        if (text.length > 3) {
                          await _peopleService.searchPeople(text);
                        }
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
          onPressed: () async {
            _loaderController.showLoader(context);
            try {
              if (_formKey.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                await Future.delayed(const Duration(milliseconds: 100),
                    () async {
                  var now = DateTimeUtils.nowUtc();
                  if (isAdd) {
                    collaborator!.createdAt = now;
                    collaborator!.createdBy = _loginService.loggedUser.email;
                    // await _driveManager.grantPermission(collaborator!.email);
                  }
                  collaborator!.modifiedAt = now;
                  collaborator!.modifiedBy = _loginService.loggedUser.email;

                  _collaboratorsRepository
                      .insertOrUpdate(collaborator!)
                      .then((c) {
                    if (c != null) {
                      developer.log('collaborator: ' + collaboratorToJson(c));
                    }
                    Navigator.of(context).pop();
                  });
                });
              }
            } catch (e) {
              showErrorDialog();
            } finally {
              _loaderController.hideLoader();
            }
          },
          child: isAdd ? const Icon(Icons.add) : const Icon(Icons.save_alt),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  Future<void> showErrorDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Error'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Can\'t share with'),
                  ],
                ),
                Container(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      collaborator!.email,
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
              ],
            ),
          ],
        );
      },
    );
  }
}
