import 'package:every_calendar/model/collaborator.dart';
import 'package:every_calendar/utils/date_time_ultils.dart';
import 'package:flutter/material.dart';

import 'add_edit_collaborator.dart';

class CollaboratorCard extends StatefulWidget {
  const CollaboratorCard({
    Key? key,
    required this.collaborator,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  final Collaborator collaborator;
  final bool isFirst;
  final bool isLast;

  @override
  State<StatefulWidget> createState() => _CollaboratorCardState();
}

class _CollaboratorCardState extends State<CollaboratorCard> {
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
            return AddEditCollaborator(
              title: 'Edit Collaborator',
              collaborator: widget.collaborator,
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
                  widget.collaborator.name[0].toUpperCase(),
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
                      widget.collaborator.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Text(
                        widget.collaborator.email,
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
                  DateTimeUtils.formatToShort(widget.collaborator.modifiedAt),
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
