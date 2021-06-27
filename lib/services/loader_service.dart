import 'package:flutter/material.dart';

class LoaderService {
  static final LoaderService _instance = LoaderService._internal();
  LoaderService._internal();

  factory LoaderService() {
    return _instance;
  }

  BuildContext? _context;
  int _counter = 0;

  void showLoader(BuildContext _context) {
    if (this._context == null) {
      this._context = _context;
    }
    _counter++;
    showDialog(
      context: this._context!,
      barrierDismissible: false,
      builder: (BuildContext _context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(""),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  Text("       "),
                  Text("Loading"),
                ],
              ),
              const Text(""),
            ],
          ),
        );
      },
    );
  }

  void hideLoader() {
    if (_context != null) {
      _counter--;
      if (_counter == 0) {
        Navigator.pop(_context!);
        _context = null;
      }
    }
  }
}
