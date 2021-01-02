import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'screens/Stampa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await FlutterConfig.loadEnvVariables();

  print(FlutterConfig.get('API_BASE_URL'));

  runApp(MyApp());
} //main

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Stampa(title: 'Stampa'),
    );
  }
}
