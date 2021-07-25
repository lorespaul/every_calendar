import 'package:flutter/cupertino.dart';

typedef HeightInjectorBuilder = Widget Function(
  BuildContext context,
  double? height,
);

class HeightInjector extends StatefulWidget {
  const HeightInjector({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final HeightInjectorBuilder builder;

  @override
  State<StatefulWidget> createState() => _HeightInjectorState();
}

class _HeightInjectorState extends State<HeightInjector> {
  double? _height;
  bool _heightCalculated = false;

  @override
  Widget build(BuildContext context) {
    if (!_heightCalculated) {
      _heightCalculated = true;
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _height = context.size?.height;
        setState(() {});
      });
    }
    return widget.builder(context, _height);
  }
}
