import 'package:flutter/material.dart';
import 'package:mek_floating_drag/mek_floating_drag.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  'You have pushed the button this many times:',
                ),
              ],
            ),
          ),
        ),
        FloatingDrag(
          elasticEdgesResolver: (containerSize, childSize) {
            return const EdgeInsets.symmetric(horizontal: -16.0, vertical: double.nan);
          },
          naturalEdgesResolver: (containerSize, childSize) {
            return const EdgeInsets.symmetric(horizontal: double.nan, vertical: 64.0);
          },
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {},
            );
          },
        ),
      ],
    );
  }
}
