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

  Widget _build(BuildContext context) {
    return const Positioned(
      bottom: 16.0,
      right: 0.0,
      left: 0.0,
      child: FloatingBallTarget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultFlyZone(
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              actions: [
                // Builder(builder: (context) {
                //   return IconButton(
                //     onPressed: () => FlyZone.of(context).show(),
                //     icon: const Icon(Icons.add),
                //   );
                // }),
              ],
            ),
            body: RestrictedFlyZone(
              child: SingleChildScrollView(
                child: Column(
                  children: Colors.primaries.map((color) {
                    return Container(
                      height: 100.0,
                      color: color,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          FloatingDart(
            naturalEdgesResolver: (containerSize, childSize) {
              return const EdgeInsets.symmetric(horizontal: double.nan, vertical: 64.0);
            },
            elasticEdgesResolver: (containerSize, childSize) {
              return const EdgeInsets.symmetric(horizontal: 0.0, vertical: double.nan);
            },
            retractEdgesResolver: (containerSize, childSize) {
              return EdgeInsets.symmetric(
                  horizontal: -(0.60 * childSize.width), vertical: double.nan);
            },
            builders: [_build],
            builder: (context) {
              return FloatingActionButton(
                onPressed: () {},
              );
            },
          ),
        ],
      ),
    );
  }
}
