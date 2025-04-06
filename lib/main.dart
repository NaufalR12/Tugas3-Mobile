import 'package:flutter/material.dart';
import 'stopwatch_page.dart';
import 'number_type_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Stopwatch & Number Type', home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Stopwatch'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StopwatchPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text('Jenis Bilangan'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NumberTypePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
