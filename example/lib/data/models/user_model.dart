import 'package:auto_entity/auto_entity.dart';

import '../../domain/entity/user_entity.dart';

part 'user_model.auto_entity.g.dart';

@AutoEntity(entity: UserEntity)
class UserModel {
  @AutoField(name: 'user_id')
  final String? id;

  @AutoField(name: 'user_name')
  final String? name;

  @AutoField(
    name: 'date_of_birth',
    toEntity: 'value == null ? null : DateTime.parse(value!)',
    fromEntity: 'value?.toIso8601String()',
  )
  final String? dob;

  @AutoField(name: 'display_name', entityName: 'displayName')
  final String? displayName;

  const UserModel({this.id, this.name, this.dob, this.displayName});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(UserEntity entity) =>
      UserModelEntityExtension.fromEntity(entity);
}
