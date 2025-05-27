import 'package:flutter/material.dart';
import 'screen2.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PhoneWidgetExample(),
      debugShowCheckedModeBanner: false,
    );
  }
}
