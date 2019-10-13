library algolia;

import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:http/http.dart'
    if (dart.library.js) 'package:node_http/node_http.dart';
import 'package:uuid/uuid.dart';

part 'src/algolia.dart';

part 'src/index_reference.dart';
part 'src/index_settings.dart';
part 'src/index_snapshot.dart';

part 'src/query.dart';
part 'src/query_snapshot.dart';

part 'src/object_snapshot.dart';
part 'src/object_reference.dart';

part 'src/batch.dart';
part 'src/task.dart';

part 'src/util/json_encode.dart';
