import 'package:every_calendar/model/activity.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'add_edit_activity.dart';

class ActivityCard extends StatefulWidget {
  const ActivityCard({
    Key? key,
    required this.activity,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  final Activity activity;
  final bool isFirst;
  final bool isLast;

  @override
  State<StatefulWidget> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
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
            return AddEditActivity(
              title: 'Edit Activity',
              activity: widget.activity,
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
                  widget.activity.duration.format(),
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
                      widget.activity.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Text(
                        widget.activity.description ?? '',
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
                  DateTimeUtils.formatToShort(widget.activity.modifiedAt),
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
