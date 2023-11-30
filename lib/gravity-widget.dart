import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:fruit_ninja/model.dart';

class FlightPathWidget extends StatefulWidget {
  final FlightPath flightPath;

  final Size unitSize;
  final double pixelsPerUnit;

  final Widget child;

  final Function() onOffScreen;

  const FlightPathWidget({Key? key, required this.flightPath, required this.unitSize, required this.pixelsPerUnit, required this.child, required this.onOffScreen})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => FlightPathWidgetState();
}

class FlightPathWidgetState extends State<FlightPathWidget> with SingleTickerProviderStateMixin {
  AnimationController? controller;

  @override
  void initState() {
    super.initState();

    List<double> zeros = widget.flightPath.zeroes;
    double time = max(zeros[0], zeros[1]);

    controller = AnimationController(
        vsync: this,
        upperBound: time + 1.0, // allow an extra second of fall time
        duration: Duration(milliseconds: ((time + 1.0) * 1000.0).round()));

    controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onOffScreen();
      }
    });

    controller!.forward();
  }

  @override
  void dispose() {
    if (controller != null) {
      controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: controller!,
      builder: (context, child) {
        Offset pos = widget.flightPath.getPosition(controller!.value) * widget.pixelsPerUnit;
        return Positioned(
          left: pos.dx - widget.unitSize.width * .5 * widget.pixelsPerUnit,
          bottom: pos.dy - widget.unitSize.height * .5 * widget.pixelsPerUnit,
          child: Transform(
            transform: Matrix4.rotationZ(widget.flightPath.getAngle(controller!.value)),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: widget.child);
}
