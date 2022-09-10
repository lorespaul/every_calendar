import 'package:every_calendar/constants/dimensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef ScaffoldContentBuilder = Widget Function(BuildContext);

class ScaffoldWrapper extends StatelessWidget {
  const ScaffoldWrapper({
    Key? key,
    this.title = "Every Calendar",
    required this.builder,
    this.actionButton,
  }) : super(key: key);

  final String title;
  final ScaffoldContentBuilder builder;
  final Widget? actionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: Dimensions.appBarHeight,
        title: Text(title),
      ),
      body: Center(
        child: builder(context),
      ),
      floatingActionButton: actionButton,
    );
  }
}
