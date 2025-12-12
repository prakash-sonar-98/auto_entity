import 'package:example/data/models/user_model.dart';
import 'package:example/domain/entity/user_entity.dart';
import 'package:flutter/material.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  UserEntity? _userEntity;
  UserModel? _fromUserEntity;

  void _getData() {
    final userModel = UserModel.fromJson({
      'user_id': '1',
      'user_name': 'Prakash',
      'display_name': 'Prakash Sonar',
      'date_of_birth': DateTime(1998, 7, 2).toIso8601String(),
    });

    // extension method on UserModel
    _userEntity = userModel.toEntity();

    // static method inside the extension
    _fromUserEntity = UserModel.fromEntity(_userEntity!);
  }

  @override
  void initState() {
    _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                'Model class data:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              _textWidget('UserId', _fromUserEntity?.id ?? ''),
              const SizedBox(height: 10),
              _textWidget('UserName', _fromUserEntity?.name ?? ''),
              const SizedBox(height: 10),
              _textWidget('DisplayName', _fromUserEntity?.displayName ?? ''),
              const SizedBox(height: 10),
              _textWidget('CreatedAt', _fromUserEntity?.dob ?? ''),
              const SizedBox(height: 20),
              Text(
                'Entity class data:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              _textWidget('UserId', _userEntity?.id ?? ''),
              const SizedBox(height: 10),
              _textWidget('UserName', _userEntity?.name ?? ''),
              const SizedBox(height: 10),
              _textWidget('DisplayName', _userEntity?.displayName ?? ''),
              const SizedBox(height: 10),
              _textWidget('CreatedAt', _userEntity?.dob?.toIso8601String() ?? ''),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textWidget(String key, String value) {
    return Row(
      children: [
        Text(key, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        Text(value),
      ],
    );
  }
}
