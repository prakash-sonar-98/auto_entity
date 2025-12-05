// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'user_model.dart';

// **************************************************************************
// AutoEntityGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['user_id'] as String?,
  name: json['user_name'] as String?,
  createdAt: json['created_at'] as String?,
  display: json['displayName'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'user_id': instance.id,
  'user_name': instance.name,
  'created_at': instance.createdAt,
  'displayName': instance.display,
};

extension UserModelEntityExtension on UserModel {
  UserEntity toEntity() => UserEntity(
    id: id,
    name: name,
    createdAt: createdAt == null ? null : DateTime.parse(createdAt!),
    displayName: display,
  );

  static UserModel fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    name: entity.name,
    createdAt: entity.createdAt?.toIso8601String(),
    display: entity.displayName,
  );
}
