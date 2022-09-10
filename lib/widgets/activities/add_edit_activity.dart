import 'dart:ui';

import 'package:every_calendar/model/activity.dart';
import 'package:every_calendar/controllers/loader_controller.dart';
import 'package:every_calendar/core/google/login_service.dart';
import 'package:every_calendar/model/value_objects/time_range.dart';
import 'package:every_calendar/repositories/activities_repository.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
import 'package:every_calendar/widgets/scaffold_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:numberpicker/numberpicker.dart';

class AddEditActivity extends StatefulWidget {
  const AddEditActivity({
    Key? key,
    required this.title,
    this.activity,
  }) : super(key: key);

  final String title;
  final Activity? activity;

  @override
  State<StatefulWidget> createState() => _AddEditActivityState();
}

class _AddEditActivityState extends State<AddEditActivity> {
  final _formKey = GlobalKey<FormState>();
  final LoaderController _loaderController = LoaderController();
  final LoginService _loginService = LoginService();
  final _textFieldStyle = const TextStyle(
    color: Colors.black,
    fontFamily: 'RobotoMono',
    fontFeatures: [FontFeature.tabularFigures()],
  );
  final _activitiesRepository = ActivitiesRepository();
  late Activity activity;
  bool isAdd = true;

  @override
  void initState() {
    super.initState();
    isAdd = widget.activity == null;
    activity = widget.activity != null
        ? Activity.fromMap(widget.activity!.toMap())
        : Activity();
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
        builder: (_) {
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
                      ),
                      style: _textFieldStyle,
                      initialValue: activity.name,
                      onChanged: (text) {
                        activity.name = text;
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          "Duration",
                          style: TextStyle(fontSize: 20),
                        ),
                        Row(
                          children: [
                            NumberPicker(
                              maxValue: 24,
                              minValue: 0,
                              value: activity.duration.intHours,
                              zeroPad: true,
                              onChanged: (value) {
                                activity.duration =
                                    TimeRange.fromHoursAndMinutes(
                                  value,
                                  activity.duration.intMinutes,
                                );
                                setState(() {});
                              },
                            ),
                            const Text(
                              "h",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            NumberPicker(
                              maxValue: 60,
                              minValue: 0,
                              value: activity.duration.intMinutes,
                              zeroPad: true,
                              onChanged: (value) {
                                activity.duration =
                                    TimeRange.fromHoursAndMinutes(
                                  activity.duration.intHours,
                                  value,
                                );
                                setState(() {});
                              },
                            ),
                            const Text(
                              "m",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 30,
                    margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Description',
                      ),
                      style: _textFieldStyle,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      initialValue: activity.description,
                      onChanged: (text) async {
                        activity.description = text;
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
            if (_formKey.currentState!.validate()) {
              FocusScope.of(context).unfocus();
              await Future.delayed(const Duration(milliseconds: 100), () async {
                var now = DateTimeUtils.nowUtc();
                if (isAdd) {
                  activity.createdAt = now;
                  activity.createdBy = _loginService.loggedUser.email;
                }
                activity.modifiedAt = now;
                activity.modifiedBy = _loginService.loggedUser.email;

                _activitiesRepository.insertOrUpdate(activity).then((a) {
                  if (a != null) {
                    developer.log('activity: ' + activityToJson(a));
                    if (widget.activity != null) {
                      widget.activity!.name = a.name;
                      widget.activity!.duration = a.duration;
                      widget.activity!.description = a.description;
                      if (isAdd) {
                        widget.activity!.createdAt = a.createdAt;
                        widget.activity!.createdBy = a.createdBy;
                      }
                      widget.activity!.modifiedAt = a.modifiedAt;
                      widget.activity!.modifiedBy = a.modifiedBy;
                    }
                  }
                  _loaderController.hideLoader();
                  Navigator.of(context).pop();
                });
              });
            }
          },
          child: isAdd ? const Icon(Icons.add) : const Icon(Icons.save_alt),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}
