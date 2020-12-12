import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _desiredTime = 60;
  int _counter;
  Timer _timer;

  _MyHomePageState() {
    _counter = _desiredTime;
    _timer = new Timer(Duration(seconds: 0), null);
    _timer.cancel();
  }

  Future<AudioPlayer> playPop() async {
    AudioCache cache = new AudioCache();
    return await cache.play("pop.mp3");
  }

  Future<AudioPlayer> playBeeps() async {
    AudioCache cache = new AudioCache();
    return await cache.play("beeps.mp3");
  }

  void _decrementCounter() {
    if (_counter <= 0) {
      playBeeps();
      _toggleTimer();
      _counter = _desiredTime;
    } else {
      if (_counter == _desiredTime ~/ 2)
        playPop();
      else if (_counter <= 5) playPop();
      setState(() {
        _counter--;
      });
    }
  }

  void _resetTimer() {
    setState(() {
      _counter = _desiredTime;
      _timer.cancel();
      _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
        _decrementCounter();
      });
    });
  }

  void _resumeTimer() {
    setState(() {
      _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
        _decrementCounter();
      });
    });
  }

  void _toggleTimer() {
    if (_timer.isActive)
      setState(() {
        _timer.cancel();
      });
    else
      _resumeTimer();
  }

  Future<void> _chooseTime() async {
    if (_timer.isActive) _toggleTimer();
    int result = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController tec = new TextEditingController();
          tec.value = TextEditingValue(text: _desiredTime.toString());
          return SimpleDialog(
            title: const Text('Enter the desired time:'),
            children: <Widget>[
              Container(
                child: Column(
                  children: [
                    Container(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: tec,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          suffix: Text('seconds'),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      padding: EdgeInsets.all(30),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceAround,
                      children: [
                        RaisedButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        RaisedButton(
                          onPressed: () {
                            try {
                              Navigator.of(context, rootNavigator: true)
                                  .pop(int.parse(tec.text));
                            } catch (e) {
                              log(e);
                            }
                          },
                          child: Text("OK"),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
    if (result != null)
      setState(() {
        _desiredTime = result;
        _counter = _desiredTime;
      });
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 6,
                // color: Colors.green,
                child: Container(
                  margin:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width * 0.05)),
                      color: Colors.white,
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.03),
                      onPressed: _chooseTime,
                      child: Icon(
                        Icons.watch_later_outlined,
                        size: MediaQuery.of(context).size.width * 0.15,
                      )),
                ),
              ),
              Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.01,
                      right: MediaQuery.of(context).size.width * 0.01),
                  // color: Colors.yellow,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2,
                    child: RaisedButton(
                        shape: CircleBorder(side: BorderSide.none),
                        color: Colors.red,
                        onPressed: () {
                          playPop();
                          if (_timer.isActive)
                            _resetTimer();
                          else
                            _toggleTimer();
                        },
                        child: Text(
                          _counter.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.4),
                        )),
                  )),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3,
                // color: Colors.blue,
                child: SizedBox(
                  width: MediaQuery.of(context).size.height / 3,
                  height: MediaQuery.of(context).size.height / 3,
                  child: FlatButton(
                    onPressed: () {
                      playPop();
                      _toggleTimer();
                    },
                    child: _timer.isActive
                        ? Icon(
                            Icons.pause,
                            size: MediaQuery.of(context).size.width * 0.4,
                            color: Colors.white,
                          )
                        : Icon(
                            Icons.play_arrow,
                            size: MediaQuery.of(context).size.width * 0.4,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
