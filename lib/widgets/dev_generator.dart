import 'package:every_calendar/controllers/loader_controller.dart';
import 'package:every_calendar/model/mock/mock_generator.dart';
import 'package:every_calendar/repositories/activities_repository.dart';
import 'package:every_calendar/repositories/collaborators_repository.dart';
import 'package:every_calendar/repositories/customers_repository.dart';
import 'package:every_calendar/widgets/scaffold_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DevGenerator extends StatelessWidget {
  DevGenerator({Key? key}) : super(key: key);

  final LoaderController _loaderController = LoaderController();
  final _collaboratorsRepository = CollaboratorsRepository();
  final _customersRepository = CustomersRepository();
  final _activitiesRepository = ActivitiesRepository();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: 'Mock',
      builder: (ctx) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => generateCollaborators(ctx),
              child: const Text("Generate 10 collaborators"),
            ),
            ElevatedButton(
              onPressed: () => generateCustomers(ctx),
              child: const Text("Generate 10 customers"),
            ),
            ElevatedButton(
              onPressed: () => generateActivities(ctx),
              child: const Text("Generate 10 activities"),
            ),
          ],
        );
      },
    );
  }

  Future<void> generateCollaborators(BuildContext context) async {
    _loaderController.showLoader(context);
    var collaborators = MockGenerator.generateCollaborators(10);
    for (var c in collaborators) {
      await _collaboratorsRepository.insert(c);
    }
    _loaderController.hideLoader();
  }

  Future<void> generateCustomers(BuildContext context) async {
    _loaderController.showLoader(context);
    var customers = MockGenerator.generateCustomers(10);
    for (var c in customers) {
      await _customersRepository.insert(c);
    }
    _loaderController.hideLoader();
  }

  Future<void> generateActivities(BuildContext context) async {
    _loaderController.showLoader(context);
    var activities = MockGenerator.generateActivities(10);
    for (var a in activities) {
      await _activitiesRepository.insert(a);
    }
    _loaderController.hideLoader();
  }
}
