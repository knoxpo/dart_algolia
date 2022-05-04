library algolia;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:universal_io/io.dart' show Platform;

part 'src/algolia.dart';
part 'src/batch.dart';
part 'src/error.dart';
part 'src/event_snapshot.dart';
part 'src/facet_value_snapshot.dart';
part 'src/index_reference.dart';
part 'src/index_settings.dart';
part 'src/index_snapshot.dart';
part 'src/object_reference.dart';
part 'src/object_snapshot.dart';
part 'src/synonyms_reference.dart';
part 'src/query.dart';
part 'src/query_snapshot.dart';
part 'src/task.dart';
part 'src/util/json_encode.dart';
part 'src/util/enum_util.dart';
