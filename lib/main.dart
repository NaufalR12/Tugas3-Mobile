import 'package:flutter/material.dart';
import 'tracking_page.dart';

void main() {
  runApp(LBSTrackingApp());
}

class LBSTrackingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LBS Tracking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TrackingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
