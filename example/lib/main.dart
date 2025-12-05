import 'package:example/user_entity.dart';
import 'package:example/user_model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UserEntity? _userEntity;
  UserModel? _fromUserEntity;

  @override
  void initState() {
    super.initState();

    final userModel = UserModel(
      id: '1',
      name: 'Alice',
      createdAt: DateTime.now().toIso8601String(),
    );

    // extension method on UserModel
    _userEntity = userModel.toEntity();

    // static method inside the extension
    _fromUserEntity = UserModel.fromEntity(_userEntity!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Text(
          'entity.createdAt: ${_userEntity?.createdAt}\n'
          'fromEntity.createdAt: ${_fromUserEntity?.createdAt}',
        ),
      ),
    );
  }
}
