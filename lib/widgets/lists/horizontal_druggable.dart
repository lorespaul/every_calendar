import 'package:flutter/cupertino.dart';

class HorizontalDruggable extends StatefulWidget {
  const HorizontalDruggable({
    Key? key,
    required this.underChild,
    required this.overChild,
    this.maxSwipe = 100,
  }) : super(key: key);

  final Widget underChild;
  final Widget overChild;
  final double maxSwipe;

  @override
  State<StatefulWidget> createState() => _HorizontalDruggableState();
}

class _HorizontalDruggableState extends State<HorizontalDruggable>
    with SingleTickerProviderStateMixin {
  double _drugValue = 0;

  late AnimationController _controller;
  late double _maxSwipe;
  late double _maxSwipeHalf;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );
    _maxSwipe = -widget.maxSwipe.abs();
    _maxSwipeHalf = _maxSwipe / 2;
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
                _animate(_maxSwipe);
              } else {
                // _drugValue = 0;
                _animate(0);
              }
              setState(() {});
            },
            child: widget.overChild,
          ),
        ),
      ],
    );
  }

  void _animate(double end) {
    var duration = (_drugValue - end).abs().ceil();
    if (duration < 70) {
      duration = 70;
    }
    _controller.duration = Duration(milliseconds: duration);
    var animation = Tween<double>(
      begin: _drugValue,
      end: end,
    ).animate(_controller);
    animation.addListener(
      () => setState(() {
        _drugValue = animation.value;
      }),
    );
    _controller.reset();
    _controller.forward();
  }
}
