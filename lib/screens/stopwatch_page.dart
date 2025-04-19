import 'package:flutter/material.dart';
import 'dart:async';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  late Stopwatch _stopwatch;
  Timer? _timer;
  final List<String> _laps = [];

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (_stopwatch.isRunning) {
        setState(() {});
      }
    });
  }

  String _formatTime(int milliseconds) {
    int hours = milliseconds ~/ (1000 * 60 * 60);
    int minutes = (milliseconds ~/ (1000 * 60)) % 60;
    int seconds = (milliseconds ~/ 1000) % 60;
    int millis = (milliseconds % 1000) ~/ 10;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${millis.toString().padLeft(2, '0')}';
  }

  void _startStopwatch() {
    setState(() {
      _stopwatch.start();
    });
  }

  void _stopStopwatch() {
    setState(() {
      _stopwatch.stop();
    });
  }

  void _addLap() {
    setState(() {
      _laps.insert(0, _formatTime(_stopwatch.elapsedMilliseconds));
    });
  }

  void _reset() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    }
    setState(() {
      _stopwatch.reset();
      _laps.clear();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _formatTime(_stopwatch.elapsedMilliseconds);
    return Scaffold(
      appBar: AppBar(title: Text('Stopwatch')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Center(
            child: Text(
              elapsed,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: !_stopwatch.isRunning ? _startStopwatch : null,
                child: Text('Start'),
              ),
              ElevatedButton(
                onPressed: _stopwatch.isRunning ? _stopStopwatch : null,
                child: Text('Stop'),
              ),
              ElevatedButton(
                onPressed: (_stopwatch.elapsedMilliseconds > 0) ? _reset : null,
                child: Text('Reset'),
              ),
              ElevatedButton(
                onPressed: _stopwatch.isRunning ? _addLap : null,
                child: Text('Lap'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text('Lap ${_laps.length - index}'),
                  title: Text(_laps[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
