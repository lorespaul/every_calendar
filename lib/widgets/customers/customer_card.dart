import 'package:every_calendar/model/customer.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'add_edit_customer.dart';

class CustomerCard extends StatefulWidget {
  const CustomerCard({
    Key? key,
    required this.customer,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  final Customer customer;
  final bool isFirst;
  final bool isLast;

  @override
  State<StatefulWidget> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
        top: widget.isFirst ? 4 : 2,
        right: 4,
        bottom: widget.isLast ? 4 : 2,
        left: 4,
      ),
      child: InkWell(
        onTap: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AddEditCustomer(
              title: 'Edit Customer',
              customer: widget.customer,
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
                  widget.customer.name[0].toUpperCase(),
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
                      widget.customer.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Text(
                        widget.customer.email,
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
                  DateTimeUtils.formatToShort(widget.customer.modifiedAt),
                  style: const TextStyle(fontSize: 11),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
