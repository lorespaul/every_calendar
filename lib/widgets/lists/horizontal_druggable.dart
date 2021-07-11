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

class _HorizontalDruggableState extends State<HorizontalDruggable>
    with SingleTickerProviderStateMixin {
  static const double _maxSwipe = -70;
  static const double _maxSwipeHalf = _maxSwipe / 2;

  double _drugValue = 0;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                // _drugValue = _maxSwipe;
                _animate(_drugValue, _maxSwipe);
              } else {
                // _drugValue = 0;
                _animate(_drugValue, 0);
              }
              setState(() {});
            },
            child: widget.overChild,
          ),
        ),
      ],
    );
  }

  void _animate(double begin, double end) {
    var duration = (begin - end).abs().ceil();
    if (duration < 70) {
      duration = 70;
    }
    _controller.duration = Duration(milliseconds: duration);
    _animation = Tween<double>(begin: begin, end: end).animate(_controller)
      ..addListener(
        () => setState(() {
          _drugValue = _animation.value;
        }),
      );
    _controller.reset();
    _controller.forward();
  }
}
