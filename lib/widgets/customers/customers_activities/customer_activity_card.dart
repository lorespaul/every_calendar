import 'package:every_calendar/model/activity.dart';
import 'package:every_calendar/model/customer.dart';
import 'package:every_calendar/model/customer_activity.dart';
import 'package:every_calendar/repositories/activities_repository.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
import 'package:flutter/material.dart';

import 'add_edit_customer_activity.dart';

class CustomerActivityCard extends StatefulWidget {
  const CustomerActivityCard({
    Key? key,
    required this.customer,
    required this.customerActivity,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  final Customer customer;
  final CustomerActivity customerActivity;
  final bool isFirst;
  final bool isLast;

  @override
  State<StatefulWidget> createState() => _CustomerActivityCardState();
}

class _CustomerActivityCardState extends State<CustomerActivityCard> {
  final _activitiesRepository = ActivitiesRepository();
  late Future<Activity?> activityFuture;

  @override
  void initState() {
    super.initState();
    activityFuture =
        _activitiesRepository.getByUuid(widget.customerActivity.uuidActivity!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Activity?>(
      future: activityFuture,
      builder: (ctx, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          var activity = snapshot.data!;
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
                    title: 'Edit Activity',
                    customer: widget.customer,
                    customerActivity: widget.customerActivity,
                    activity: activity,
                  );
                })).then((value) => setState(() {}));
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.black26,
                      ),
                      margin: const EdgeInsets.only(left: 0),
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      alignment: Alignment.center,
                      child: Text(
                        widget.customerActivity.duration.format(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            child: Text(
                              activity.description ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.only(right: 0),
                      child: Text(
                        DateTimeUtils.formatToShort(activity.modifiedAt),
                        style: const TextStyle(fontSize: 11),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const Text('Error');
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        );
      },
    );
  }
}
