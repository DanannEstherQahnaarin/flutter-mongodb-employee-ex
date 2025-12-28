import 'package:flutter/material.dart';
import 'package:flutter_mongodb_employee_ex01/screen/list_emp_screen.dart';
import 'package:flutter_mongodb_employee_ex01/services/mongo_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DB 연결 시도
  await MongoDatabase().connect();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Mongo Employee App')),
        body: EmployeeListScreen(),
      ),
    );
  }
}
