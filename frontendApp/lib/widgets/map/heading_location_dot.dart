import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:frontend_app/widgets/map/heading_cone_painter.dart';


class HeadingLocationDot extends StatefulWidget {
  final double size;
  final Color color;

  const HeadingLocationDot({
    super.key,
    this.size = 90,
    this.color = Colors.orange,
  });

  @override
  State<HeadingLocationDot> createState() => _HeadingLocationDotState();
}

class _HeadingLocationDotState extends State<HeadingLocationDot>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  StreamSubscription<CompassEvent>? _compassSub;

  double _rawHeading = 0.0;

  double _displayHeading = 0.0;

  late final AnimationController _headingAnimController;
  Animation<double>? _headingAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _headingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _subscribeToCompass();
  }

  void _subscribeToCompass() {
    if (FlutterCompass.events == null) return; // device has no sensor
    _compassSub = FlutterCompass.events!.listen((event) {
      if (!mounted || event.heading == null) return;
      _updateHeading(event.heading!);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _compassSub ??= FlutterCompass.events?.listen((event) {
        if (!mounted || event.heading == null) return;
        _updateHeading(event.heading!);
      });
    } else if (state == AppLifecycleState.paused) {
      // Stop listening while backgrounded to save battery.
      _compassSub?.cancel();
      _compassSub = null;
    }
  }


  void _updateHeading(double newRawHeading) {
    const smoothingFactor = 0.15;
    final delta = _shortestAngleDelta(_rawHeading, newRawHeading);
    _rawHeading = (_rawHeading + delta * smoothingFactor) % 360;
    if (_rawHeading < 0) _rawHeading += 360;

    final start = _displayHeading;
    final targetDelta = _shortestAngleDelta(start, _rawHeading);
    final end = start + targetDelta;

    _headingAnimation = Tween<double>(begin: start, end: end).animate(
      CurvedAnimation(parent: _headingAnimController, curve: Curves.linear),
    )..addListener(() {
      if (mounted) {
        setState(() => _displayHeading = _headingAnimation!.value % 360);
      }
    });

    _headingAnimController
      ..reset()
      ..forward();
  }

  double _shortestAngleDelta(double from, double to) {
    double delta = (to - from) % 360;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;
    return delta;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _compassSub?.cancel();
    _headingAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.size * 0.18;
    final ringSize = dotSize + 8;
    final haloSize = widget.size;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: haloSize,
          height: haloSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.08),
          ),
        ),
        Transform.rotate(
          angle: (_displayHeading * math.pi) / 180,
          child: CustomPaint(
            size: Size(haloSize, haloSize),
            painter: HeadingConePainter(color: widget.color),
          ),
        ),
        Container(
          width: ringSize,
          height: ringSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ],
    );
  }
}