import 'package:every_calendar/model/collaborator.dart';
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
}
