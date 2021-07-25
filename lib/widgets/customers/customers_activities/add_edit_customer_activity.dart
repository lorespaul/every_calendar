import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:every_calendar/controllers/loader_controller.dart';
import 'package:every_calendar/core/google/login_service.dart';
import 'package:every_calendar/model/customer_activity.dart';
import 'package:every_calendar/repositories/customers_activities_repository.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class AddEditCustomerActivity extends StatefulWidget {
  const AddEditCustomerActivity({
    Key? key,
    required this.title,
    this.customerActivity,
  }) : super(key: key);

  final String title;
  final CustomerActivity? customerActivity;

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
  );
  final _customersActivitiesRepository = CustomersActivitiesRepository();
  late CustomerActivity customerActivity;
  bool isAdd = true;

  @override
  void initState() {
    super.initState();
    isAdd = widget.customerActivity == null;
    customerActivity = widget.customerActivity != null
        ? CustomerActivity.fromMap(widget.customerActivity!.toMap())
        : CustomerActivity();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        FocusScope.of(context).requestFocus(FocusNode());
        return Future.delayed(const Duration(milliseconds: 100), () => true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Form(
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
                    // initialValue: customerActivity.name,
                    // onChanged: (text) {
                    //   customer.name = text;
                    // },
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
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Email *',
                    ),
                    style: _textFieldStyle,
                    keyboardType: TextInputType.emailAddress,
                    // initialValue: customer.email,
                    // onChanged: (text) async {
                    //   customer.email = text;
                    //   if (text.length > 3) {
                    //     await _peopleService.searchPeople(text);
                    //   }
                    // },
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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            _loaderController.showLoader(context);
            try {
              if (_formKey.currentState!.validate()) {
                FocusScope.of(context).unfocus();
                await Future.delayed(const Duration(milliseconds: 100),
                    () async {
                  var now = DateTimeUtils.nowUtc();
                  if (isAdd) {
                    customerActivity.createdAt = now;
                    customerActivity.createdBy = _loginService.loggedUser.email;
                  }
                  customerActivity.modifiedAt = now;
                  customerActivity.modifiedBy = _loginService.loggedUser.email;

                  _customersActivitiesRepository
                      .insertOrUpdate(customerActivity)
                      .then((ca) {
                    if (ca != null) {
                      developer.log('customer: ' + customerActivityToJson(ca));
                      if (widget.customerActivity != null) {
                        // widget.customerActivity!.name = ca.name;
                        // widget.customerActivity!.email = ca.email;
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
                  children: const [
                    Text(
                      // customer.email,
                      '',
                      style: TextStyle(fontSize: 20),
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
