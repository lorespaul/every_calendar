import 'package:every_calendar/core/google/login_service.dart';
import 'package:googleapis/people/v1.dart';
import 'dart:developer' as developer;

class PeopleService {
  static final PeopleService _instance = PeopleService._internal();
  PeopleService._internal();

  factory PeopleService() {
    return _instance;
  }

  final LoginService _loginService = LoginService();
  PeopleServiceApi? _peopleApi;

  PeopleServiceApi getPeopleApi() {
    _peopleApi ??= PeopleServiceApi(_loginService.authClient);
    return _peopleApi!;
  }

  Future<void> searchPeople(String email) async {
    var peopleApi = getPeopleApi();
    var result = await peopleApi.otherContacts.search(
      pageSize: 5,
      query: email,
      readMask: 'emailAddresses',
    );
    developer.log(result.toJson().toString());
  }
}
