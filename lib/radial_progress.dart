import 'dart:async';

import 'package:battery/battery.dart';
import 'package:battery_checker/radial_painter.dart';
import 'package:flutter/material.dart';

class RadialProgress extends StatefulWidget {
  final double goalCompleted = 0.95;

  @override
  _RadialProgressState createState() => _RadialProgressState();
}

class _RadialProgressState extends State<RadialProgress>
    with SingleTickerProviderStateMixin {
  double progressDegrees = 0;
  var count = 0;

  Battery _battery = Battery();
  int batteryPercentage = 0;
  StreamSubscription<BatteryState> _batteryStateSubscription;

  @override
  void initState() {
    super.initState();
    setState(() {
      // progressDegrees = widget.goalCompleted * _progressAnimation.value;
    });
    getBatteryLevel();
  }

  getBatteryLevel() async {
    while (batteryPercentage < 100) {
      final int batteryLevel = await _battery.batteryLevel;
      setState(() {
        // Future.delayed(Duration(seconds: 60));
        batteryPercentage = batteryLevel;
        progressDegrees = batteryPercentage * 3.6;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_batteryStateSubscription != null) {
      _batteryStateSubscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: Container(
        height: 180.0,
        width: 180.0,
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Text(
              'BATTERY',
              style: TextStyle(fontSize: 24.0, letterSpacing: 1.5),
            ),
            SizedBox(
              height: 4.0,
            ),
            Container(
              height: 5.0,
              width: 80.0,
              decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.all(Radius.circular(4.0))),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              '$batteryPercentage%',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      painter: RadialPainter(progressDegrees),
    );
  }
}
