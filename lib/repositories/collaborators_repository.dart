import 'package:every_calendar/core/db/abstract_repository.dart';
import 'package:every_calendar/model/collaborator.dart';

class CollaboratorsRepository extends AbstractRepository<Collaborator> {
  @override
  getEntityInstance() => Collaborator();
}
