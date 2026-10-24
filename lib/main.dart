import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const LeanMetricApp());
}

class LeanMetricApp extends StatelessWidget {
  const LeanMetricApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '减脂记录',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}