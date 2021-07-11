import 'package:flutter/cupertino.dart';

class HorizontalDruggable extends StatefulWidget {
  const HorizontalDruggable({
    Key? key,
    required this.underChild,
    required this.overChild,
  }) : super(key: key);

  final Widget underChild;
  final Widget overChild;

  @override
  State<StatefulWidget> createState() => _HorizontalDruggableState();
}

class _HorizontalDruggableState extends State<HorizontalDruggable> {
  static const double _maxSwipe = -70;
  static const double _maxSwipeHalf = _maxSwipe / 2;

  double _drugValue = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.underChild,
        Positioned.fill(
          left: _drugValue,
          right: -_drugValue,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              _drugValue = _drugValue + details.delta.dx;
              setState(() {});
            },
            onHorizontalDragEnd: (details) {
              if (_drugValue < _maxSwipeHalf) {
                _drugValue = _maxSwipe;
              } else {
                _drugValue = 0;
              }
              setState(() {});
            },
            child: widget.overChild,
          ),
        ),
      ],
    );
  }
}
