import 'package:every_calendar/widgets/scaffold_wrapper.dart';
import 'package:flutter/cupertino.dart';

class TenantManager extends StatelessWidget {
  const TenantManager({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: title,
      builder: () {
        return const Text("Ciaone");
      },
    );
  }
}
