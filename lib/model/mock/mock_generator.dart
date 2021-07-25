import 'package:every_calendar/model/activity.dart';
import 'package:every_calendar/model/collaborator.dart';
import 'package:every_calendar/model/customer.dart';
import 'package:every_calendar/model/value_objects/time_range.dart';
import 'package:random_string/random_string.dart';

class MockGenerator {
  static List<Collaborator> generateCollaborators(int quantity) {
    List<Collaborator> collaborators = [];
    for (var i = 0; i < quantity; i++) {
      collaborators.add(Collaborator(
        name: randomAlpha(randomBetween(5, 9)),
        email: randomAlpha(randomBetween(8, 13)) + '@gmail.com',
      ));
    }
    return collaborators;
  }

  static List<Customer> generateCustomers(int quantity) {
    List<Customer> customers = [];
    for (var i = 0; i < quantity; i++) {
      customers.add(Customer(
        name: randomAlpha(randomBetween(5, 9)),
        email: randomAlpha(randomBetween(8, 13)) + '@gmail.com',
      ));
    }
    return customers;
  }

  static List<Activity> generateActivities(int quantity) {
    List<Activity> activities = [];
    int minDuration = TimeRange.minValue().toMilliseconds(); // in milliseconds
    int maxDuration = TimeRange.maxValue().toMilliseconds(); // in milliseconds
    for (var i = 0; i < quantity; i++) {
      activities.add(Activity(
        name: randomAlpha(randomBetween(5, 9)),
        description: randomAlpha(randomBetween(13, 200)),
        duration: TimeRange.fromMilliseconds(
          randomBetween(minDuration, maxDuration),
        ),
      ));
    }
    return activities;
  }
}
