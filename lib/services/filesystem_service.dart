import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FilesystemService {
  static final FilesystemService _instance = FilesystemService._internal();
  FilesystemService._internal();

  Directory? _appDocumentsDirectory;

  factory FilesystemService() {
    return _instance;
  }

  static const String _tenantLocalFileName = "tenant.json";

  Future<Directory> getAppDocumentsDirectory() async {
    _appDocumentsDirectory ??= await getApplicationDocumentsDirectory();
    return _appDocumentsDirectory!;
  }

  Future<File> getTenantFile() async {
    final directory = await getAppDocumentsDirectory();
    return File('${directory.path}/$_tenantLocalFileName');
  }

  Future<String> getTenantFileJson() async {
    final tenantFile = await getTenantFile();
    return tenantFile.readAsString();
  }
}
