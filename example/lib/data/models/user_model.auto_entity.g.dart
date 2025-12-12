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
  dob: json['date_of_birth'] as String?,
  displayName: json['display_name'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'user_id': instance.id,
  'user_name': instance.name,
  'date_of_birth': instance.dob,
  'display_name': instance.displayName,
};

extension UserModelEntityExtension on UserModel {
  UserEntity toEntity() => UserEntity(
    id: id,
    name: name,
    dob: dob == null ? null : DateTime.parse(dob!),
    displayName: displayName,
  );

  static UserModel fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    name: entity.name,
    dob: entity.dob?.toIso8601String(),
    displayName: entity.displayName,
  );
}
