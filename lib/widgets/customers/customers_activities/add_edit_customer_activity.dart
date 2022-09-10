import 'dart:ui';

import 'package:every_calendar/controllers/loader_controller.dart';
import 'package:every_calendar/core/google/login_service.dart';
import 'package:every_calendar/model/activity.dart';
import 'package:every_calendar/model/customer.dart';
import 'package:every_calendar/model/customer_activity.dart';
import 'package:every_calendar/model/value_objects/time_range.dart';
import 'package:every_calendar/repositories/activities_repository.dart';
import 'package:every_calendar/repositories/customers_activities_repository.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
import 'package:every_calendar/widgets/scaffold_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:numberpicker/numberpicker.dart';

class AddEditCustomerActivity extends StatefulWidget {
  const AddEditCustomerActivity({
    Key? key,
    required this.title,
    required this.customer,
    this.customerActivity,
    this.activity,
  }) : super(key: key);

  final String title;
  final Customer customer;
  final CustomerActivity? customerActivity;
  final Activity? activity;

  @override
  State<StatefulWidget> createState() => _AddEditCustomerActivityState();
}

class _AddEditCustomerActivityState extends State<AddEditCustomerActivity> {
  final _formKey = GlobalKey<FormState>();
  final LoaderController _loaderController = LoaderController();
  final LoginService _loginService = LoginService();
  final _textFieldStyle = const TextStyle(
    color: Colors.black,
    fontFamily: 'RobotoMono',
    fontFeatures: [FontFeature.tabularFigures()],
    fontSize: 18,
  );
  static const double _edgeMargin = 20;
  final _rowMargin = const EdgeInsets.only(
    top: _edgeMargin,
    right: _edgeMargin,
    left: _edgeMargin,
  );
  final _activitiesRepository = ActivitiesRepository();
  final _customersActivitiesRepository = CustomersActivitiesRepository();
  late CustomerActivity customerActivity;
  bool isAdd = true;
  Activity? activity;

  @override
  void initState() {
    super.initState();
    isAdd = widget.customerActivity == null;
    customerActivity = widget.customerActivity != null
        ? CustomerActivity.fromMap(widget.customerActivity!.toMap())
        : CustomerActivity();
    activity = widget.activity;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: _rowMargin,
                  child: Row(
                    children: [
                      SizedBox(
                        width:
                            MediaQuery.of(context).size.width / 2 - _edgeMargin,
                        child: Text(
                          "Customer name",
                          style: _textFieldStyle,
                        ),
                      ),
                      Text(
                        widget.customer.name,
                        style: _textFieldStyle,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: _rowMargin,
                  child: Row(
                    children: [
                      SizedBox(
                        width:
                            MediaQuery.of(context).size.width / 2 - _edgeMargin,
                        child: Text(
                          "Customer email",
                          style: _textFieldStyle,
                        ),
                      ),
                      SizedBox(
                        width:
                            MediaQuery.of(context).size.width / 2 - _edgeMargin,
                        child: Text(
                          widget.customer.email,
                          overflow: TextOverflow.ellipsis,
                          style: _textFieldStyle,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: _rowMargin,
                  child: Row(
                    children: [
                      SizedBox(
                        width:
                            MediaQuery.of(context).size.width / 2 - _edgeMargin,
                        child: Text(
                          "Activity name",
                          style: _textFieldStyle,
                        ),
                      ),
                      FutureBuilder<List<Activity>>(
                        future: _activitiesRepository.getAllWithoutCustomer(
                          widget.customer.uuid,
                          actualUuidActivity: activity?.uuid ?? '',
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Activity> activities = snapshot.data!;
                            return DropdownButton<Activity>(
                              hint: const Text('Select activity'),
                              value: activity,
                              onChanged: (a) {
                                setState(() => activity = a);
                              },
                              items: activities.map((a) {
                                return DropdownMenuItem<Activity>(
                                  value: a,
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        a.name,
                                        style:
                                            const TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          } else if (snapshot.hasError) {
                            return const Text('Error');
                          }
                          return const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.green),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: _edgeMargin / 2,
                    left: _edgeMargin,
                    right: _edgeMargin,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width:
                            MediaQuery.of(context).size.width / 2 - _edgeMargin,
                        child: Text(
                          "Activity description",
                          style: _textFieldStyle,
                        ),
                      ),
                      SizedBox(
                        width:
                            MediaQuery.of(context).size.width / 2 - _edgeMargin,
                        child: activity != null
                            ? Text(
                                activity!.description ?? ' - ',
                                overflow: TextOverflow.ellipsis,
                                style: _textFieldStyle,
                              )
                            : Text(
                                ' - ',
                                style: _textFieldStyle,
                              ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: _rowMargin,
                  child: Row(
                    children: [
                      SizedBox(
                        width:
                            MediaQuery.of(context).size.width / 2 - _edgeMargin,
                        child: Text(
                          "Activity duration",
                          style: _textFieldStyle,
                        ),
                      ),
                      activity != null
                          ? Text(
                              activity!.duration.format(),
                              style: _textFieldStyle,
                            )
                          : Text(
                              ' - ',
                              style: _textFieldStyle,
                            ),
                    ],
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
                            value: customerActivity.duration.intHours,
                            zeroPad: true,
                            onChanged: (value) {
                              customerActivity.duration =
                                  TimeRange.fromHoursAndMinutes(
                                value,
                                customerActivity.duration.intMinutes,
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
                            value: customerActivity.duration.intMinutes,
                            zeroPad: true,
                            onChanged: (value) {
                              customerActivity.duration =
                                  TimeRange.fromHoursAndMinutes(
                                customerActivity.duration.intHours,
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
              ],
            ),
          );
        },
        actionButton: FloatingActionButton(
          onPressed: () async {
            _loaderController.showLoader(context);
            try {
              if (_formKey.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                var now = DateTimeUtils.nowUtc();
                if (isAdd) {
                  customerActivity.createdAt = now;
                  customerActivity.createdBy = _loginService.loggedUser.email;
                }
                customerActivity.modifiedAt = now;
                customerActivity.modifiedBy = _loginService.loggedUser.email;
                customerActivity.uuidCustomer = widget.customer.uuid;
                customerActivity.uuidActivity = activity!.uuid;

                _customersActivitiesRepository
                    .insertOrUpdate(customerActivity)
                    .then((ca) {
                  if (ca != null) {
                    developer.log('customer: ' + customerActivityToJson(ca));
                    if (widget.customerActivity != null) {
                      widget.customerActivity!.uuidCustomer = ca.uuidCustomer;
                      widget.customerActivity!.uuidActivity = ca.uuidActivity;
                      widget.customerActivity!.duration = ca.duration;
                      if (isAdd) {
                        widget.customerActivity!.createdAt = ca.createdAt;
                        widget.customerActivity!.createdBy = ca.createdBy;
                      }
                      widget.customerActivity!.modifiedAt = ca.modifiedAt;
                      widget.customerActivity!.modifiedBy = ca.modifiedBy;
                    }
                  }
                  Navigator.of(context).pop();
                });
              }
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
}
