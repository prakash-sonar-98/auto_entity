library;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/auto_entity_generator.dart';

Builder autoEntityBuilder(BuilderOptions options) =>
    PartBuilder(const [AutoEntityGenerator()], '.auto_entity.g.dart');
