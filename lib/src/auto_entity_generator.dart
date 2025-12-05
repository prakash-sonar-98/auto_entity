import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import './annotations.dart';

/// Match fields annotated with @AutoField.
/// We try both a fully qualified URL and a simple type name as fallback.
final _autoFieldChecker = TypeChecker.any([
  const TypeChecker.fromUrl('package:auto_entity/auto_entity.dart#AutoField'),
  TypeChecker.typeNamed(AutoField),
]);

/// Match classes annotated with @AutoEntity.
final _autoEntityChecker = TypeChecker.any([
  const TypeChecker.fromUrl('package:auto_entity/auto_entity.dart#AutoEntity'),
  TypeChecker.typeNamed(AutoEntity),
]);

class AutoEntityGenerator extends GeneratorForAnnotation<AutoEntity> {
  const AutoEntityGenerator();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@AutoEntity can only be used on classes.',
        element: element,
      );
    }

    final classElement = element;
    final className = classElement.name;

    final entityType = annotation.peek('entity')?.typeValue;
    final entityName = entityType?.getDisplayString();

    final buffer = StringBuffer();

    // ------------------------------------------------------------------
    // Header
    // ------------------------------------------------------------------
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// ignore_for_file: unused_element');
    buffer.writeln();

    // ------------------------------------------------------------------
    // Build field metadata
    // ------------------------------------------------------------------
    final fields = _generateTargetFields(
      classElement,
    ).map(_buildFieldMapping).toList();

    // ------------------------------------------------------------------
    // json_serializable-style fromJson
    // ------------------------------------------------------------------
    buffer.writeln(
      '$className _\$${className}FromJson(Map<String, dynamic> json) => $className(',
    );

    for (final m in fields) {
      final expr = _fromJsonValue(m);
      buffer.writeln('  ${m.field.displayName}: $expr,');
    }

    buffer.writeln(');');
    buffer.writeln();

    // ------------------------------------------------------------------
    // json_serializable-style toJson
    // ------------------------------------------------------------------
    buffer.writeln(
      'Map<String, dynamic> _\$${className}ToJson($className instance) => <String, dynamic>{',
    );

    for (final m in fields) {
      final expr = _toJsonValue(m);
      buffer.writeln("  '${m.jsonKey}': $expr,");
    }

    buffer.writeln('};');
    buffer.writeln();

    // ------------------------------------------------------------------
    // Entity mapping extension
    // ------------------------------------------------------------------
    // IMPORTANT: no leading underscore -> public extension
    final extensionName = '${className}EntityExtension';
    buffer.writeln('extension $extensionName on $className {');

    if (entityName != null) {
      // toEntity()
      buffer.writeln('  $entityName toEntity() => $entityName(');
      for (final m in fields) {
        final rhs = _buildToEntityValue(m);
        buffer.writeln('    ${m.entityFieldName}: $rhs,');
      }
      buffer.writeln('  );');
      buffer.writeln();

      // fromEntity() – static on the extension
      // NOTE: You call this as: ClassNameEntityExtension.fromEntity(entity)
      buffer.writeln(
        '  static $className fromEntity($entityName entity) => $className(',
      );
      for (final m in fields) {
        final rhs = _buildFromEntityValue(m, 'entity');
        buffer.writeln('    ${m.field.displayName}: $rhs,');
      }
      buffer.writeln('  );');
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  // ----------------------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------------------

  Iterable<FieldElement> _generateTargetFields(ClassElement classElement) {
    return classElement.fields.where((field) {
      if (field.isStatic || field.isSynthetic) return false;

      final ann = _autoFieldChecker.firstAnnotationOf(field);
      if (ann == null) return true;

      final reader = ConstantReader(ann);
      final ignore = reader.peek('ignore')?.boolValue ?? false;
      return !ignore;
    });
  }
}

class _FieldMapping {
  final FieldElement field;
  final String jsonKey;
  final String entityFieldName;
  final String? toEntityExpr;
  final String? fromEntityExpr;

  const _FieldMapping({
    required this.field,
    required this.jsonKey,
    required this.entityFieldName,
    this.toEntityExpr,
    this.fromEntityExpr,
  });
}

_FieldMapping _buildFieldMapping(FieldElement field) {
  final ann = _autoFieldChecker.firstAnnotationOf(field);
  if (ann == null) {
    return _FieldMapping(
      field: field,
      jsonKey: field.displayName,
      entityFieldName: field.displayName,
    );
  }

  final reader = ConstantReader(ann);
  final jsonName = reader.peek('name')?.stringValue;
  final entityName = reader.peek('entityName')?.stringValue;
  final toEntity = reader.peek('toEntity')?.stringValue;
  final fromEntity = reader.peek('fromEntity')?.stringValue;

  String normalize(String? v, String fallback) =>
      (v == null || v.isEmpty) ? fallback : v;

  return _FieldMapping(
    field: field,
    jsonKey: normalize(jsonName, field.displayName),
    entityFieldName: normalize(entityName, field.displayName),
    toEntityExpr: (toEntity == null || toEntity.isEmpty) ? null : toEntity,
    fromEntityExpr: (fromEntity == null || fromEntity.isEmpty)
        ? null
        : fromEntity,
  );
}

// ----------------------------------------------------------------------
// JSON helpers (json_serializable-style, with DateTime support)
// ----------------------------------------------------------------------

String _fromJsonValue(_FieldMapping m) {
  final type = m.field.type;
  final key = m.jsonKey;

  final isNullable = type.nullabilitySuffix == NullabilitySuffix.question;
  final coreType = type.getDisplayString();

  // DateTime / DateTime?
  if (coreType == 'DateTime') {
    if (isNullable) {
      return "json['$key'] == null "
          "? null "
          ": DateTime.parse(json['$key'] as String)";
    } else {
      return "DateTime.parse(json['$key'] as String)";
    }
  }

  // List<DateTime> / List<DateTime>?
  if (type.isDartCoreList && type is ParameterizedType) {
    final itemType = type.typeArguments.first;
    final itemCore = itemType.getDisplayString();

    if (itemCore == 'DateTime') {
      if (isNullable) {
        return "json['$key'] == null "
            "? null "
            ": (json['$key'] as List<dynamic>)"
            ".map((e) => DateTime.parse(e as String))"
            ".toList()";
      } else {
        return "(json['$key'] as List<dynamic>)"
            ".map((e) => DateTime.parse(e as String))"
            ".toList()";
      }
    }
  }

  // Default: cast as the field type
  final castType = type.getDisplayString();
  return "json['$key'] as $castType";
}

String _toJsonValue(_FieldMapping m) {
  final type = m.field.type;
  final name = m.field.displayName;

  final isNullable = type.nullabilitySuffix == NullabilitySuffix.question;
  final coreType = type.getDisplayString();

  // DateTime / DateTime?
  if (coreType == 'DateTime') {
    return isNullable
        ? 'instance.$name?.toIso8601String()'
        : 'instance.$name.toIso8601String()';
  }

  // List<DateTime> / List<DateTime>?
  if (type.isDartCoreList && type is ParameterizedType) {
    final itemType = type.typeArguments.first;
    final itemCore = itemType.getDisplayString();

    if (itemCore == 'DateTime') {
      return isNullable
          ? 'instance.$name?.map((e) => e.toIso8601String()).toList()'
          : 'instance.$name.map((e) => e.toIso8601String()).toList()';
    }
  }

  // Default
  return 'instance.$name';
}

// ----------------------------------------------------------------------
// Entity mapping helpers
// ----------------------------------------------------------------------

String _buildToEntityValue(_FieldMapping m) {
  final field = m.field;
  final fieldName = field.displayName;
  final DartType type = field.type;

  final isNullable = type.nullabilitySuffix == NullabilitySuffix.question;

  // Custom expression from @AutoField
  if (m.toEntityExpr != null) {
    return m.toEntityExpr!.replaceAll('value', fieldName);
  }

  // List<AutoEntity> / List<AutoEntity>?
  if (type.isDartCoreList && type is ParameterizedType) {
    final itemType = type.typeArguments.first;

    if (_isAutoEntityType(itemType)) {
      if (isNullable) {
        return '$fieldName?.map((e) => e.toEntity()).toList()';
      } else {
        return '$fieldName.map((e) => e.toEntity()).toList()';
      }
    }

    return fieldName;
  }

  // Nested AutoEntity / AutoEntity?
  if (_isAutoEntityType(type)) {
    if (isNullable) {
      return '$fieldName?.toEntity()';
    } else {
      return '$fieldName.toEntity()';
    }
  }

  // Direct mapping
  return fieldName;
}

String _buildFromEntityValue(_FieldMapping m, String entityParamName) {
  final field = m.field;
  final DartType type = field.type;

  final isNullable = type.nullabilitySuffix == NullabilitySuffix.question;

  final source = '$entityParamName.${m.entityFieldName}';

  // Custom expression from @AutoField
  if (m.fromEntityExpr != null) {
    return m.fromEntityExpr!.replaceAll('value', source);
  }

  // List<Entity> -> List<Model> / List<Model>?
  if (type.isDartCoreList && type is ParameterizedType) {
    final itemType = type.typeArguments.first;
    if (_isAutoEntityType(itemType)) {
      final modelTypeName = itemType.getDisplayString();

      if (isNullable) {
        return '$source?.map($modelTypeName.fromEntity).toList()';
      } else {
        return '$source.map($modelTypeName.fromEntity).toList()';
      }
    }
    return source;
  }

  // Nested AutoEntity / AutoEntity?
  if (_isAutoEntityType(type)) {
    final modelTypeName = type.getDisplayString();

    if (isNullable) {
      return '$source != null ? $modelTypeName.fromEntity($source) : null';
    } else {
      return '$modelTypeName.fromEntity($source)';
    }
  }

  // Direct mapping
  return source;
}

bool _isAutoEntityType(DartType type) {
  final element = type.element;
  if (element is! ClassElement) return false;
  return _autoEntityChecker.hasAnnotationOf(element);
}
