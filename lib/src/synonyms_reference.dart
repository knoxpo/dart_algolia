part of algolia;

enum SynonymsType {
  synonym,
  onewaysynonym,
  altcorrection1,
  altcorrection2,
  placeholder,
}

extension ExtensionDietaryType on SynonymsType {
  String toMap() {
    return toString().split('.').last;
  }

  String get label {
    return toMap().split(RegExp(r'(?=[A-Z])')).join(' ');
  }
}

///
/// **AlgoliaSynonymsReference**
///
/// A AlgoliaSynonymsReference object can be used for adding object's synonyms, getting
/// synonyms references, manage the index synonyms for objects.
///
class AlgoliaSynonymsReference {
  const AlgoliaSynonymsReference._(this.algolia, this.index);
  final String index;
  final Algolia algolia;

  ///
  /// ID of the referenced index.
  ///
  String get encodedIndex => Uri.encodeFull(index);

  ///
  /// **Search synonyms**
  ///
  /// Search or browse all synonyms, optionally filtering them by type.
  ///
  /// - `query`: Search for specific synonyms matching this string. Use an
  /// empty string (default) to browse all synonyms.
  ///
  /// - `type`: Only search for specific types of synonyms. Multiple types
  /// can be specified using a comma-separated list. Possible values are:
  /// synonym, onewaysynonym, altcorrection1, altcorrection2, placeholder.
  ///
  /// - `page`: Number of the page to retrieve (zero-based).
  ///
  /// - `hitsPerPage`: Maximum number of synonym objects to retrieve.
  ///
  Future<Map<String, dynamic>> search({
    String? query,
    SynonymsType? type,
    int page = 0,
    int hitsPerPage = 100,
  }) async {
    var data = {
      'query': query,
      'type': type,
      'page': page,
      'hitsPerPage': hitsPerPage,
    };
    data.removeWhere((key, value) => value == null);
    var response = await algolia._apiCall(
      ApiRequestType.post,
      'indexes/$encodedIndex/synonyms/search',
      data: data,
    );
    Map<String, dynamic> body = json.decode(response.body);
    if (!(response.statusCode >= 200 && response.statusCode < 500)) {
      throw AlgoliaError._(body, response.statusCode);
    }
    return body;
  }

  ///
  /// **Save Synonym**
  ///
  /// Create a new synonym object or update the existing synonym object with
  /// the given object ID.
  /// The body of the request must be a JSON object representing the
  /// synonyms. It must contain the following attributes:
  /// - `objectID` (string): Unique identifier of the synonym object to be created or updated.
  /// - `type` (string): Type of the synonym object (see below).
  ///
  /// The rest of the body depends on the type of synonyms to add:
  /// ---
  /// ### `synonym` Multi-way synonyms (a.k.a. “regular synonyms”).
  /// A set of words or phrases that are all substitutable to one another. Any query containing
  /// one of them can match records containing any of them. The body must contain the following
  /// fields:
  /// - `synonyms` (array of strings): Words or phrases to be considered equivalent.
  /// ---
  /// ### `onewaysynonym` One-way synonym.
  /// Alternative matches for a given input. If the input appears
  /// inside a query, it will match records containing any of the defined synonyms. The opposite
  /// is not true: if a synonym appears in a query, it will not match records containing the
  /// input, nor the other synonyms. The body must contain the following fields:
  /// - `input` (string): Word or phrase to appear in query strings.
  /// - `synonyms` (array of strings): Words or phrases to be matched in records.
  /// ---
  /// ### `altcorrection1`, `altcorrection2` Alternative corrections.
  /// Same as a one-way synonym, except that when matched, they will count as 1 (respectively 2)
  /// typos in the ranking formula. The body must contain the following fields:
  /// - `word` (string): Word or phrase to appear in query strings.
  /// - `corrections` (array of strings): Words to be matched in records. Phrases (multiple-word
  /// synonyms) are not supported.
  /// ---
  /// ### `placeholder` Placeholder:
  /// A placeholder is a special text token that is placed inside records and can match many
  /// inputs. The body must contain the following fields:
  /// - `placeholder` (string): Token to be put inside records.
  /// - `replacements` (array of strings): List of query words that will match the token.
  ///
  /// ---
  /// `forwardToReplicas`: (URL parameter) Replicate the new/updated synonym set to all replica
  /// indices. [default: false]
  ///
  Future<AlgoliaTask> save(AlgoliaSynonyms synonyms) async {
    var response = await algolia._apiCall(
      ApiRequestType.put,
      'indexes/$encodedIndex/synonyms/${synonyms.objectID}?forwardToReplicas=${synonyms.forwardToReplicas}',
      data: synonyms.toMap(),
    );
    Map<String, dynamic> body = json.decode(response.body);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }
    return AlgoliaTask._(algolia, index, body);
  }

  ///
  /// **Save synonyms (Batch)**
  ///
  /// Create/update multiple synonym objects at once, potentially replacing the entire list of
  /// synonyms if `replaceExistingSynonyms` is true.
  ///
  Future<AlgoliaTask> batch(List<AlgoliaSynonyms> synonyms) async {
    var response = await algolia._apiCall(
      ApiRequestType.post,
      'indexes/$encodedIndex/synonyms/batch',
      data: synonyms.map((e) => e.toMap()).toList(),
    );
    Map<String, dynamic> body = json.decode(response.body);
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }
    return AlgoliaTask._(algolia, index, body);
  }

  ///
  /// **Get synonym**
  ///
  /// Fetch a synonym object identified by its `objectID`.
  ///
  Future<Map<String, dynamic>> getByObjectId(String objectID) async {
    var response = await algolia._apiCall(
      ApiRequestType.get,
      'indexes/$encodedIndex/synonyms/$objectID',
    );
    Map<String, dynamic> body = json.decode(response.body);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }
    return body;
  }

  ///
  /// **Clear all synonyms**
  ///
  /// Delete all synonyms from the index.
  ///
  Future<AlgoliaTask> clear() async {
    var response = await algolia._apiCall(
      ApiRequestType.post,
      'indexes/$encodedIndex/synonyms/clear',
    );
    Map<String, dynamic> body = json.decode(response.body);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }
    return AlgoliaTask._(algolia, index, body);
  }

  ///
  /// **Delete synonym**
  ///
  /// Delete a single synonyms set, identified by the given `objectID`.
  ///
  Future<AlgoliaTask> delete(String objectID) async {
    var response = await algolia._apiCall(
      ApiRequestType.post,
      'indexes/$encodedIndex/synonyms/$objectID',
    );
    Map<String, dynamic> body = json.decode(response.body);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }
    return AlgoliaTask._(algolia, index, body);
  }
}

///
/// The body of the request must be a JSON object representing the
/// synonyms. It must contain the following attributes:
/// - `objectID` (string): Unique identifier of the synonym object to be created or updated.
/// - `type` (string): Type of the synonym object (see below).
///
/// The rest of the body depends on the type of synonyms to add:
/// ---
/// ### `synonym` Multi-way synonyms (a.k.a. “regular synonyms”).
/// A set of words or phrases that are all substitutable to one another. Any query containing
/// one of them can match records containing any of them. The body must contain the following
/// fields:
/// - `synonyms` (array of strings): Words or phrases to be considered equivalent.
/// ---
/// ### `onewaysynonym` One-way synonym.
/// Alternative matches for a given input. If the input appears
/// inside a query, it will match records containing any of the defined synonyms. The opposite
/// is not true: if a synonym appears in a query, it will not match records containing the
/// input, nor the other synonyms. The body must contain the following fields:
/// - `input` (string): Word or phrase to appear in query strings.
/// - `synonyms` (array of strings): Words or phrases to be matched in records.
/// ---
/// ### `altcorrection1`, `altcorrection2` Alternative corrections.
/// Same as a one-way synonym, except that when matched, they will count as 1 (respectively 2)
/// typos in the ranking formula. The body must contain the following fields:
/// - `word` (string): Word or phrase to appear in query strings.
/// - `corrections` (array of strings): Words to be matched in records. Phrases (multiple-word
/// synonyms) are not supported.
/// ---
/// ### `placeholder` Placeholder:
/// A placeholder is a special text token that is placed inside records and can match many
/// inputs. The body must contain the following fields:
/// - `placeholder` (string): Token to be put inside records.
/// - `replacements` (array of strings): List of query words that will match the token.
///
/// ---
/// `forwardToReplicas`: (URL parameter) Replicate the new/updated synonym set to all replica
/// indices. [default: false]
///
class AlgoliaSynonyms {
  final String objectID;
  final SynonymsType type;
  final List<String>? synonyms;
  final List<String>? corrections;
  final List<String>? replacements;
  final String? input;
  final String? word;
  final String? placeholder;
  final bool forwardToReplicas;
  const AlgoliaSynonyms({
    required this.objectID,
    required this.type,
    this.synonyms,
    this.corrections,
    this.replacements,
    this.input,
    this.word,
    this.placeholder,
    this.forwardToReplicas = false,
  })  : assert(
            (type == SynonymsType.synonym && synonyms != null) ||
                type != SynonymsType.synonym,
            '`synonyms` (array of strings): Words or phrases to be considered equivalent.'),
        assert(
            (type == SynonymsType.onewaysynonym &&
                    synonyms != null &&
                    input != null) ||
                type != SynonymsType.onewaysynonym,
            ' - `input` (string): Word or phrase to appear in query strings. \n - `synonyms` (array of strings): Words or phrases to be matched in records.'),
        assert(
            (type == SynonymsType.altcorrection1 &&
                    corrections != null &&
                    word != null) ||
                type != SynonymsType.altcorrection1,
            '- `word` (string): Word or phrase to appear in query strings. \n - `corrections` (array of strings): Words to be matched in records. Phrases (multiple-word synonyms) are not supported.'),
        assert(
            (type == SynonymsType.altcorrection2 &&
                    corrections != null &&
                    word != null) ||
                type != SynonymsType.altcorrection2,
            '- `word` (string): Word or phrase to appear in query strings. \n - `corrections` (array of strings): Words to be matched in records. Phrases (multiple-word synonyms) are not supported.'),
        assert(
            (type == SynonymsType.placeholder &&
                    replacements != null &&
                    placeholder != null) ||
                type != SynonymsType.placeholder,
            '- `placeholder` (string): Token to be put inside records. \n - `replacements` (array of strings): List of query words that will match the token.');

  AlgoliaSynonyms copyWith({
    String? objectID,
    SynonymsType? type,
    List<String>? synonyms,
    List<String>? corrections,
    List<String>? replacements,
    String? input,
    String? word,
    String? placeholder,
    bool? forwardToReplicas,
  }) {
    return AlgoliaSynonyms(
      objectID: objectID ?? this.objectID,
      type: type ?? this.type,
      synonyms: synonyms ?? this.synonyms,
      corrections: corrections ?? this.corrections,
      replacements: replacements ?? this.replacements,
      input: input ?? this.input,
      word: word ?? this.word,
      placeholder: placeholder ?? this.placeholder,
      forwardToReplicas: forwardToReplicas ?? this.forwardToReplicas,
    );
  }

  Map<String, dynamic> toMap() {
    var val = {
      'objectID': objectID,
      'type': type.toMap(),
      'synonyms': synonyms,
      'corrections': corrections,
      'replacements': replacements,
      'input': input,
      'word': word,
      'placeholder': placeholder,
    };
    val.removeWhere((key, value) => value == null);
    return val;
  }

  factory AlgoliaSynonyms.fromMap(Map<String, dynamic> map) {
    return AlgoliaSynonyms(
      objectID: map['objectID'],
      type: EnumUtil.fromStringEnum<SynonymsType>(
          SynonymsType.values, map['type']),
      synonyms:
          map['synonyms'] != null ? List<String>.from(map['synonyms']) : null,
      corrections: map['corrections'] != null
          ? List<String>.from(map['corrections'])
          : null,
      replacements: map['replacements'] != null
          ? List<String>.from(map['replacements'])
          : null,
      input: map['input'],
      word: map['word'],
      placeholder: map['placeholder'],
      forwardToReplicas: map['forwardToReplicas'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AlgoliaSynonyms.fromJson(String source) =>
      AlgoliaSynonyms.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AlgoliaSynonyms(objectID: $objectID, type: $type, synonyms: $synonyms, corrections: $corrections, replacements: $replacements, input: $input, word: $word, placeholder: $placeholder, forwardToReplicas: $forwardToReplicas)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AlgoliaSynonyms &&
        other.objectID == objectID &&
        other.type == type &&
        other.synonyms == synonyms &&
        other.corrections == corrections &&
        other.replacements == replacements &&
        other.input == input &&
        other.word == word &&
        other.placeholder == placeholder &&
        other.forwardToReplicas == forwardToReplicas;
  }

  @override
  int get hashCode {
    return objectID.hashCode ^
        type.hashCode ^
        synonyms.hashCode ^
        corrections.hashCode ^
        replacements.hashCode ^
        input.hashCode ^
        word.hashCode ^
        placeholder.hashCode ^
        forwardToReplicas.hashCode;
  }
}
