import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:every_calendar/core/db/abstract_entity.dart';
import 'package:every_calendar/core/google/people_service.dart';
import 'package:every_calendar/controllers/loader_controller.dart';
import 'package:every_calendar/core/google/login_service.dart';
import 'package:every_calendar/model/customer.dart';
import 'package:every_calendar/repositories/customers_repository.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
import 'package:every_calendar/widgets/customers/customers_activities/add_edit_customer_activity.dart';
import 'package:every_calendar/widgets/customers/customers_activities/customer_activities_list.dart';
import 'package:every_calendar/widgets/scaffold_wrapper.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class AddEditCustomer extends StatefulWidget {
  const AddEditCustomer({
    Key? key,
    required this.title,
    required this.onSync,
    this.customer,
  }) : super(key: key);

  final String title;
  final Customer? customer;
  final Future Function(String, AbstractEntity?) onSync;

  @override
  State<StatefulWidget> createState() => _AddEditCustomerState();
}

class _AddEditCustomerState extends State<AddEditCustomer> {
  final _formKey = GlobalKey<FormState>();
  GlobalKey _addPageKey = GlobalKey();
  final LoaderController _loaderController = LoaderController();
  final LoginService _loginService = LoginService();
  final PeopleService _peopleService = PeopleService();
  final _textFieldStyle = const TextStyle(
    color: Colors.black,
    fontFamily: 'RobotoMono',
    fontFeatures: [FontFeature.tabularFigures()],
  );
  final _customersRepository = CustomersRepository();
  late Customer customer;
  bool isAdd = true;

  @override
  void initState() {
    super.initState();
    isAdd = widget.customer == null;
    customer = widget.customer != null
        ? Customer.fromMap(widget.customer!.toMap())
        : Customer();
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
                      ),
                      style: _textFieldStyle,
                      initialValue: customer.name,
                      onChanged: (text) {
                        customer.name = text;
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
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Email *',
                      ),
                      style: _textFieldStyle,
                      keyboardType: TextInputType.emailAddress,
                      initialValue: customer.email,
                      onChanged: (text) async {
                        customer.email = text;
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
                  Container(
                    width: MediaQuery.of(context).size.width - 30,
                    margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const AddEditCustomerActivity(
                                title: 'Add Customer activity',
                              );
                            })).then(
                              (value) => setState(() {
                                _addPageKey = GlobalKey();
                              }),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.add_circle_outline),
                              Container(
                                width: 10,
                              ),
                              const Text('Override activity'),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  CustomerActivitiesList(
                    key: _addPageKey,
                    customer: customer,
                    onSync: widget.onSync,
                  )
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
                    customer.createdAt = now;
                    customer.createdBy = _loginService.loggedUser.email;
                  }
                  customer.modifiedAt = now;
                  customer.modifiedBy = _loginService.loggedUser.email;

                  _customersRepository.insertOrUpdate(customer).then((c) {
                    if (c != null) {
                      developer.log('customer: ' + customerToJson(c));
                      if (widget.customer != null) {
                        widget.customer!.name = c.name;
                        widget.customer!.email = c.email;
                        if (isAdd) {
                          widget.customer!.createdAt = c.createdAt;
                          widget.customer!.createdBy = c.createdBy;
                        }
                        widget.customer!.modifiedAt = c.modifiedAt;
                        widget.customer!.modifiedBy = c.modifiedBy;
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
                  children: [
                    Text(
                      customer.email,
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
