/// Marks a class as a generated model with:
/// - toJson / fromJson (json_serializable-style)
/// - toEntity / fromEntity (mapping to another class)
class AutoEntity {
  /// Optional: the Entity type to map to/from.
  final Type? entity;

  const AutoEntity({this.entity});
}

/// Field-level customization for JSON and entity mapping.
class AutoField {
  /// JSON key name (for toJson/fromJson).
  /// If null, uses the Dart field name.
  final String? name;

  /// Entity field name if it’s different from the model field name.
  final String? entityName;

  /// Custom expression when converting Model -> Entity.
  ///
  /// Use `value` as a placeholder for the model field value.
  ///
  /// Example:
  ///   @AutoField(toEntity: 'DateTime.parse(value)')
  final String? toEntity;

  /// Custom expression when converting Entity -> Model.
  ///
  /// Use `value` as a placeholder for the entity field value.
  ///
  /// Example:
  ///   @AutoField(fromEntity: 'value.toIso8601String()')
  final String? fromEntity;

  /// Ignore this field in JSON and entity mapping.
  final bool ignore;

  const AutoField({
    this.name,
    this.entityName,
    this.toEntity,
    this.fromEntity,
    this.ignore = false,
  });
}
