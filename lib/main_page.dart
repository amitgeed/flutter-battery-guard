import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:battery/battery.dart';
import 'package:battery_checker/radial_progress.dart';
import 'package:battery_checker/top_bar.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  static const String id = "main_screen";
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Battery _battery = Battery();
  int batteryPercentage = 0;
  BatteryState _batteryState;
  String batteryCurrentState;
  bool alarmStatus = false;
  int batteryAlarm = 80;
  int alarmBatteryLevel = 80;
  StreamSubscription<BatteryState> _batteryStateSubscription;

  @override
  void initState() {
    super.initState();
    _batteryStateSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() {
        _batteryState = state;
        if (_batteryState.toString() == 'BatteryState.charging') {
          batteryCurrentState = 'Charging';
        } else if (_batteryState.toString() == 'BatteryState.discharging') {
          batteryCurrentState = 'Charger Not Connected';
        } else if (_batteryState.toString() == 'BatteryState.full') {
          batteryCurrentState = 'Battery is Full';
        }
      });
    });
    getBatteryLevel();
    // callAlarm();
  }

  getBatteryLevel() async {
    while (batteryPercentage <= 100) {
      final int batteryLevel = await _battery.batteryLevel;
      setState(() {
        batteryPercentage = batteryLevel;
      });
    }
  }

  callAlarm() {
    if (batteryPercentage >= alarmBatteryLevel) {
      final player = AudioCache();
      player.play('note1.mp3');
    }
  }

  ringAlarm() {
    if (alarmStatus) {
      Timer(Duration(seconds: 3), () {
        callAlarm();
        ringAlarm();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Stack(
            children: [
              TopBar(),
              Positioned(
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Text(
                          'Battery Guard',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          RadialProgress(),
          Text(
            "$batteryCurrentState",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color:
                  batteryCurrentState == "Charging" ? Colors.green : Colors.red,
            ),
          ),
          Card(
            margin: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Ring Alarm On",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "$batteryAlarm%",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SliderTheme(
                  data: SliderThemeData(
                      thumbColor: Colors.deepPurple,
                      activeTrackColor: Colors.deepPurpleAccent,
                      inactiveTrackColor: Colors.deepPurpleAccent.shade100,
                      trackHeight: 5.0,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 12.0),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 25.0)),
                  child: Slider(
                      max: 98.0,
                      min: 50.0,
                      value: batteryAlarm.toDouble(),
                      onChanged: (double neValue) {
                        setState(() {
                          batteryAlarm = neValue.round();
                        });
                      }),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (alarmStatus) {
                  alarmStatus = false;
                } else {
                  alarmStatus = true;
                }
                if (alarmStatus) {
                  alarmBatteryLevel = batteryAlarm;
                } else {
                  alarmBatteryLevel = 100;
                }
              });
              ringAlarm();
            },
            child: Container(
              width: double.infinity,
              height: 70.0,
              color: Colors.deepPurple,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  alarmStatus ? "STOP" : "START",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_batteryStateSubscription != null) {
      _batteryStateSubscription.cancel();
    }
  }
}
