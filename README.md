# Auto Entity

A lightweight Flutter/Dart code generator for:

✅ JSON `fromJson` / `toJson` generation (like `json_serializable`)  
✅ Seamless Model ⇄ Entity mapping  
✅ Field renaming for JSON and Entity layers  
✅ Built‑in `DateTime` handling (nullable + lists)  
✅ Custom converters via simple expressions

---

## Features

### ✅ JSON serialization

Automatically generates:

```dart
factory Model.fromJson(Map<String, dynamic> json)
Map<String, dynamic> toJson()
```

Supports:

- `DateTime.parse()` / `.toIso8601String()`
- Nullable fields
- `List<T>` and `List<DateTime>`
- Standard Dart types

---

### ✅ Entity mapping

Also generates:

```dart
extension _$ModelEntityExtension on Model {
  Entity toEntity();
  static Model fromEntity(Entity entity);
}
```

---

### ✅ Field control with `@AutoField`

Customize each field:

- JSON key → `name`
- Entity field name → `entityName`
- Conversion expressions → `toEntity`, `fromEntity`
- Skip fields → `ignore: true`

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  auto_entity: ^1.0.0

dev_dependencies:
  build_runner: ^2.10.4
```

---

## Usage

### 1. Define your Entity

```dart
class UserEntity {
  final String id;
  final String name;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}
```

---

### 2. Define your Model

```dart
import 'package:auto_entity/auto_entity.dart';

part 'user_model.auto_entity.g.dart';

@AutoEntity(entity: UserEntity)
class UserModel {
  @AutoField(name: 'user_id')
  final String? id;

  @AutoField(name: 'user_name')
  final String? name;

  @AutoField(
    name: 'created_at',
    toEntity: 'value == null ? null : DateTime.parse(value!)',
    fromEntity: 'value?.toIso8601String()',
  )
  final String? createdAt;

  @AutoField(name: 'displayName', entityName: 'displayName')
  final String? display;

  const UserModel({this.id, this.name, this.createdAt, this.display});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(UserEntity entity) =>
      UserModelEntityExtension.fromEntity(entity);
}
```

---

### 3. Run generator

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Field Renaming

### JSON name

```dart
@AutoField(name: 'created_at')
final DateTime createdAt;
```

### Entity name

```dart
@AutoField(entityName: 'displayName')
final String display;
```

---

## Custom Converters

```dart
@AutoField(
  name: 'created_at',
  toEntity: 'DateTime.parse(value)',
  fromEntity: 'value.toIso8601String()',
)
final String createdAt;
```

### Nullable

```dart
@AutoField(
  toEntity: 'value == null ? null : DateTime.parse(value)',
  fromEntity: 'value?.toIso8601String()',
)
final String? createdAt;
```

---

## Ignoring Fields

```dart
@AutoField(ignore: true)
final String tempOnly;
```

---

## Automatic Type Support

| Type | JSON | Entity |
|------|------|---------|
| String | ✅ | ✅ |
| int | ✅ | ✅ |
| bool | ✅ | ✅ |
| double | ✅ | ✅ |
| DateTime | ✅ | ✅ |
| DateTime? | ✅ | ✅ |
| List<T> | ✅ | ✅ |
| List<DateTime> | ✅ | ✅ |
| Nested AutoEntity | ✅ | ✅ |
| List<AutoEntity> | ✅ | ✅ |

---

## Formatting

```bash
dart format .
```

---

## License

MIT
