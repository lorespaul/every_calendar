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
  final Future Function(String, List<AbstractEntity>) onSync;

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
                    margin: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            var c = await saveCustomer();
                            if (c != null) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return AddEditCustomerActivity(
                                  title: 'Add Customer activity',
                                  customer: c,
                                );
                              })).then(
                                (value) => setState(() {
                                  _addPageKey = GlobalKey();
                                }),
                              );
                            }
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
                  Expanded(
                    child: Stack(
                      children: [
                        CustomerActivitiesList(
                          key: _addPageKey,
                          customer: customer,
                          onSync: widget.onSync,
                        ),
                        Positioned(
                          top: -5,
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              border: const Border(
                                top: BorderSide(
                                  width: 1,
                                  color: Colors.black45,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        actionButton: FloatingActionButton(
          onPressed: () async {
            await Future.delayed(const Duration(milliseconds: 100), () async {
              await saveCustomer();
            });
            Navigator.of(context).pop();
          },
          child: isAdd ? const Icon(Icons.add) : const Icon(Icons.save_alt),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  Future<Customer?> saveCustomer() async {
    _loaderController.showLoader(context);
    try {
      if (_formKey.currentState!.validate()) {
        FocusScope.of(context).unfocus();
        var now = DateTimeUtils.nowUtc();
        if (isAdd) {
          customer.createdAt = now;
          customer.createdBy = _loginService.loggedUser.email;
        }
        customer.modifiedAt = now;
        customer.modifiedBy = _loginService.loggedUser.email;

        var c = await _customersRepository.insertOrUpdate(customer);

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
        return c;
      }
    } finally {
      _loaderController.hideLoader();
    }
    return null;
  }
}
