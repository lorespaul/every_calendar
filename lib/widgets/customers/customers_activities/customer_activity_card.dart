import 'package:every_calendar/model/customer_activity.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'add_edit_customer_activity.dart';

class CustomerActivityCard extends StatefulWidget {
  const CustomerActivityCard({
    Key? key,
    required this.customerActivity,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  final CustomerActivity customerActivity;
  final bool isFirst;
  final bool isLast;

  @override
  State<StatefulWidget> createState() => _CustomerActivityCardState();
}

class _CustomerActivityCardState extends State<CustomerActivityCard> {
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
            return AddEditCustomerActivity(
              title: 'Edit Customer activity',
              customerActivity: widget.customerActivity,
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
                child: const Text(
                  // widget.customer.name[0].toUpperCase(),
                  '',
                  style: TextStyle(
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
                    // Text(
                    //   widget.customerActivity.name,
                    //   style: const TextStyle(
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: const Text(
                        // widget.customer.email,
                        '',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(right: 20),
                child: Text(
                  DateTimeUtils.formatToShort(
                      widget.customerActivity.modifiedAt),
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
