import 'package:flutter/cupertino.dart';

class HorizontalDruggable extends StatefulWidget {
  const HorizontalDruggable({
    Key? key,
    required this.underChild,
    required this.overChild,
    this.maxSwipe = 100,
    this.onDismiss,
  }) : super(key: key);

  final Widget underChild;
  final Widget overChild;
  final double maxSwipe;
  final void Function()? onDismiss;

  @override
  State<StatefulWidget> createState() => _HorizontalDruggableState();
}

class _HorizontalDruggableState extends State<HorizontalDruggable>
    with SingleTickerProviderStateMixin {
  double _drugValue = 0;

  late AnimationController _controller;
  late double _maxSwipe;
  late double _maxSwipeHalf;
  bool _animateOutCalled = false;
  bool _animateHeightCalled = false;
  double? _height;

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
    if (widget.onDismiss != null && !_animateOutCalled) {
      _animateOutCalled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _animateOut());
    } else if (_animateHeightCalled) {
      return SizedBox(height: _height);
    }

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
                _animate(_maxSwipe);
              } else {
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

  Future _animate(
    double end, {
    int? duration,
    bool curved = true,
  }) {
    if (duration == null) {
      duration = (_drugValue - end).abs().ceil();
      if (duration < 70) {
        duration = 70;
      }
    }
    _controller.duration = Duration(milliseconds: duration);
    var animation = Tween<double>(
      begin: _drugValue,
      end: end,
    ).animate(
      curved
          ? CurvedAnimation(
              parent: _controller,
              curve: Curves.easeOutCubic,
            )
          : _controller,
    );
    animation.addListener(
      () => setState(() {
        _drugValue = animation.value;
      }),
    );
    _controller.reset();
    return _controller.forward();
  }

  Future _animateHeight() {
    _controller.duration = const Duration(milliseconds: 150);
    var animation = Tween<double>(
      begin: _height,
      end: 0,
    ).animate(_controller);
    animation.addListener(
      () => setState(() {
        _height = animation.value;
      }),
    );
    _controller.reset();
    return _controller.forward();
  }

  void _animateOut() {
    var end = -MediaQuery.of(context).size.width;
    _animate(end, duration: 150, curved: false).then((v1) {
      _height = context.size?.height;
      _animateHeightCalled = true;
      _animateHeight().then(
        (v2) {
          widget.onDismiss?.call();
          _drugValue = 0;
          _animateOutCalled = false;
          _animateHeightCalled = false;
          _height = null;
        },
      );
    });
  }
}
