part of algolia;

enum AlgoliaSortFacetValuesBy {
  alpha,
  count,
}

///
/// **AlgoliaQuery**
///
/// Represents a query over the data about search parameters.
///
class AlgoliaQuery {
  AlgoliaQuery._(
      {required this.algolia,
      required String index,
      Map<String, dynamic>? parameters})
      : _index = index,
        _parameters = parameters ??
            Map<String, dynamic>.unmodifiable(<String, dynamic>{
              'facetFilters':
                  List<List<dynamic>>.unmodifiable(<List<dynamic>>[]),
              'optionalFilters':
                  List<List<String>>.unmodifiable(<List<String>>[]),
              'numericFilters':
                  List<List<String>>.unmodifiable(<List<String>>[]),
              'tagFilters': List<List<String>>.unmodifiable(<List<String>>[]),
            });
  final Algolia algolia;
  final String _index;
  final Map<String, dynamic> _parameters;

  Map<String, dynamic> get parameters => _parameters;
  String get encodedIndex => Uri.encodeFull(_index);

  AlgoliaQuery _copyWithParameters(Map<String, dynamic> parameters) {
    return AlgoliaQuery._(
      algolia: algolia,
      index: _index,
      parameters: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(_parameters)..addAll(parameters),
      ),
    );
  }

  /// Obtains a AlgoliaIndex corresponding to this query's location.
  AlgoliaIndexReference reference() => AlgoliaIndexReference._(algolia, _index);

  @override
  String toString() {
    return {
      'url': '${algolia._host}indexes' +
          (encodedIndex.isNotEmpty ? '/' + encodedIndex : ''),
      'headers': algolia._headers,
      'parameters': _parameters,
    }.toString();
  }

  ///
  /// **GetObjects**
  ///
  /// This will execute the query and retrieve data from Algolia with [AlgoliaQuerySnapshot]
  /// response.
  ///
  Future<AlgoliaQuerySnapshot> getObjects() async {
    if (_parameters.containsKey('minimumAroundRadius')) {
      assert(
          (_parameters.containsKey('aroundLatLng') ||
              _parameters.containsKey('aroundLatLngViaIP')),
          'This setting only works within the context of a circular geo search, enabled by `aroundLatLng` or `aroundLatLngViaIP`.');
    }
    if (_parameters['attributesToRetrieve'] == null) {
      _copyWithParameters(<String, dynamic>{
        'attributesToRetrieve': const ['*']
      });
    }
    var response = await algolia._apiCall(
      ApiRequestType.post,
      'indexes/$encodedIndex/query',
      data: _parameters,
    );
    Map<String, dynamic> body = json.decode(response.body);
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }

    return AlgoliaQuerySnapshot._(algolia, _index, body);
  }

  ///
  /// **DeleteObjects**
  ///
  /// This will execute the query and retrieve data from Algolia with [AlgoliaQuerySnapshot]
  /// response.
  ///
  Future<AlgoliaQuerySnapshot> deleteObjects() async {
    if (_parameters.containsKey('minimumAroundRadius')) {
      assert(
          (_parameters.containsKey('aroundLatLng') ||
              _parameters.containsKey('aroundLatLngViaIP')),
          'This setting only works within the context of a circular geo search, enabled by `aroundLatLng` or `aroundLatLngViaIP`.');
    }
    if (_parameters['attributesToRetrieve'] == null) {
      _copyWithParameters(<String, dynamic>{
        'attributesToRetrieve': const ['*']
      });
    }
    var response = await algolia._apiCall(
      ApiRequestType.post,
      'indexes/$encodedIndex/deleteByQuery',
      data: _parameters,
    );
    Map<String, dynamic> body = json.decode(response.body);
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }

    return AlgoliaQuerySnapshot._(algolia, _index, body);
  }

  ///
  /// **Search (query)**
  ///
  /// The text to search in the index.
  ///
  /// **Usage notes:**
  ///   - If the text is empty or absent, the search will match every object in your index.
  ///   - In our documentation, we use the terms [query], “query terms”, or “search text” to mean the same thing, namely: the text used to search the index.
  ///   - There’s a hard limit of 512 characters per query. If a search query is longer, the API will return an error.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/query/)
  ///
  @Deprecated(
      'Use `query(String value)` instead. This method will be deprecated from version ^1.1.0')
  AlgoliaQuery search(String value) {
    assert(!_parameters.containsKey('search'));
    return _copyWithParameters(<String, dynamic>{'query': value});
  }

  ///
  /// **Query**
  ///
  /// The text to search in the index.
  ///
  /// **Usage notes:**
  ///   - If the text is empty or absent, the search will match every object in your index.
  ///   - In our documentation, we use the terms [query], “query terms”, or “search text” to mean the same thing, namely: the text used to search the index.
  ///   - There’s a hard limit of 512 characters per query. If a search query is longer, the API will return an error.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/query/)
  ///
  AlgoliaQuery query(String value) {
    assert(!_parameters.containsKey('search'));
    return _copyWithParameters(<String, dynamic>{'query': value});
  }

  ///
  /// **SimilarQuery)**
  ///
  /// Overrides the query parameter and performs a more generic search that can be used to find “similar” results.
  ///
  /// **Usage notes:**
  ///   - similarQuery should be constructed from the tags and keywords of the object you are trying to find related results to.
  ///   - similarQuery is not automatically generated. You need to select which keywords you think would be useful.
  ///     For example, a similarQuery for a movie could use the genre, principle actors, and tags attributes. After extracting information from those categories, you might end up with a similarQuery that looks like: “Romance Comedy Gordon-Levitt NY”. Check out the examples section for a more detailed walk-through.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/similarQuery/)
  ///
  @Deprecated(
      'Use `similarQuery(String value)` instead. This method will be deprecated from version ^1.1.0')
  AlgoliaQuery setSimilarQuery(String value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('similarQuery'));
    return _copyWithParameters(<String, dynamic>{'similarQuery': value});
  }

  ///
  /// **SimilarQuery)**
  ///
  /// Overrides the query parameter and performs a more generic search that can be used to find “similar” results.
  ///
  /// **Usage notes:**
  ///   - similarQuery should be constructed from the tags and keywords of the object you are trying to find related results to.
  ///   - similarQuery is not automatically generated. You need to select which keywords you think would be useful.
  ///     For example, a similarQuery for a movie could use the genre, principle actors, and tags attributes. After extracting information from those categories, you might end up with a similarQuery that looks like: “Romance Comedy Gordon-Levitt NY”. Check out the examples section for a more detailed walk-through.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/similarQuery/)
  ///
  AlgoliaQuery similarQuery(String value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('similarQuery'));
    return _copyWithParameters(<String, dynamic>{'similarQuery': value});
  }

  ///
  /// **SearchableAttributes**
  ///
  /// The complete list of attributes used for searching.
  ///
  /// This setting is critical to establishing excellent relevance for two main reasons:
  ///   - It limits the scope of a search to the listed attributes.
  ///     Defining specific attributes as searchable gives you direct control over what information the search engine should look at.
  ///     Some attributes contain URLs; others exist for display purposes only. Such attributes are not useful for searching.
  ///   - It creates a priority order between attributes which the engine uses to improve relevance.
  ///     The order in which the attributes appear determines their search priority.
  ///     Records with matches in the first attribute(s) of the list score higher on the [attribute criterion] than records with matches in the second attribute(s), which score higher than records with matches in the third attribute(s), and so on.
  ///
  /// This setting helps reduce your response size and improve performance.
  ///
  ///
  /// **Usage notes:**
  ///  - Default/empty list: if you don’t use this setting, or use it with an empty list, the engine searches in all attributes.
  ///  - Ordering: in addition to creating attribute-level priority, you can also determine how the engine searches within an attribute.
  ///    By default, the engine favors matches at the beginning of an attribute, but you can change it to ignore positioning and consider any match within an attribute of equal importance.
  ///  - Same priority: you can create the same priority for several attributes by setting them in the same comma-separated string.
  ///    Attributes that are on the same priority as others are always unordered.
  ///  - Nested attributes: when you specify an attribute with nested attributes, the engine indexes them all.
  ///    If you don’t want to search the full attribute, you can reference a child attribute (e.g., categories.lvl0.child_attribute.sub_child_attribute).
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/searchableAttributes/)
  ///
  AlgoliaQuery setSearchableAttributes(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('searchableAttributes'));
    return _copyWithParameters(
        <String, dynamic>{'searchableAttributes': value});
  }

  ///
  /// **AttributesForFaceting**
  ///
  /// The complete list of attributes that will be used for faceting.
  ///
  /// Use this setting for 2 reasons:
  ///   - to turn an attribute into a facet.
  ///   - o make any string attribute filterable.
  ///
  /// By default, your index comes with no categories. By designating an attribute as a facet,
  /// this enables Algolia to compute a set of possible values that can later be used to filter results or display these categories.
  /// You can also get a count of records that match those values.
  ///
  ///
  /// **Usage notes:**
  ///  - This setting enables both faceting and filtering.
  ///    - Faceting allows you to use attributes inside [facets]
  ///    - Filtering allows you to use attributes inside filters, facetFilters and optionalFilter
  ///  - Default: If not specified or empty, no attribute will be faceted.
  ///  - Nested Attributes: All attributes can be used for faceting, even when nested.
  ///    For example, authors.mainAuthor can be used for faceting. Here the faceting will be applied only on mainAuthor.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributesForFaceting/)
  ///
  AlgoliaQuery setAttributesForFaceting(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('attributesForFaceting'));
    return _copyWithParameters(
        <String, dynamic>{'attributesForFaceting': value});
  }

  ///
  /// **UnRetrievableAttributes**
  ///
  /// List of attributes that cannot be retrieved at query time.
  ///
  /// You may want to ensure that under no circumstance should a particular set of attributes be returned.
  /// This is particularly important for security or business reasons, where some attributes are used only for ranking or other technical purposes, but should never be seen by your end users, for example, total_sales, permissions, and other private information.
  /// This setting guarantees
  ///
  /// **Usage notes:**
  ///  - These attributes can still be used for indexing and/or ranking.
  ///  - This setting is bypassed when the query is authenticated with the [admin API key].
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/unretrievableAttributes/)
  ///
  AlgoliaQuery setUnRetrievableAttributes(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('unretrievableAttributes'));
    return _copyWithParameters(
        <String, dynamic>{'unretrievableAttributes': value});
  }

  ///
  /// **AttributesToRetrieve**
  ///
  /// Gives control over which attributes to retrieve and which not to retrieve.
  ///
  /// You don’t always need to retrieve a full response that includes every attribute in your index. Sometimes you may only want to receive the most relevant attributes, or exclude attributes used only for internal purposes.
  ///
  /// This setting helps reduce your response size and improve performance.
  ///
  ///
  /// **Usage notes:**
  ///  - Special Characters:
  ///    - Use * to retrieve all values.
  ///    - Append a dash (-) to an attribute that you do NOT wish to retrieve. Example below. Without prefixing an attribute with -, the attribute will be retrieved.
  ///    - Note that negative attributes (-) only work when using *. For example, [“*”, “-title”] retrieves every attribute except “title”.
  ///  - [objectID] is always retrieved, even when not specified.
  ///  - Also note that using negative attributes doesn’t make them unsearchable. If your users make queries that match an attribute not to retrieve, they will still get the same results, but the attribute won’t be part of the response.
  ///  - Attributes listed in [unretrievableAttributes] will not be retrieved even if requested, unless the request is authenticated with the admin API key.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributesToRetrieve/)
  ///
  AlgoliaQuery setAttributesToRetrieve(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('attributesToRetrieve'));
    return _copyWithParameters(
        <String, dynamic>{'attributesToRetrieve': value});
  }

  ///
  /// **RestrictSearchableAttributes**
  ///
  /// Restricts a given query to look in only a subset of your searchable attributes.
  ///
  /// This setting overrides [searchableAttributes] for specific searches.
  ///
  ///
  /// **Usage notes:**
  ///   - This setting is a query-level setting, affecting only the search that specifies it.
  ///   - [searchableAttributes] must not be empty nor null for [restrictSearchableAttributes] to be applied.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/restrictSearchableAttributes/)
  ///
  AlgoliaQuery setRestrictSearchableAttributes(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('restrictSearchableAttributes'));
    return _copyWithParameters(
        <String, dynamic>{'restrictSearchableAttributes': value});
  }

  ///
  /// **Filters**
  ///
  /// Filter the query with numeric, facet and/or tag filters.
  ///
  /// This parameter uses SQL-like syntax, where you can use boolean operators and parentheses to combine individual filters.
  ///
  /// ---
  ///
  /// ***Numeric Comparisons***
  ///
  /// Format: `${attributeName} ${operator} ${value}`
  /// Example: `price > 12.99`
  ///
  /// The `${value}` must be numeric. Supported operators are `<`, `<=`, `=`, `!=`, `>=` and `>`, with the same semantics as in virtually all programming languages.
  ///
  /// ---
  ///
  /// ***Numeric Range***
  ///
  /// Format: `${attributeName}:${lowerBound} TO ${upperBound}`
  /// Example: `price:5.99 TO 100`
  ///
  /// `${lowerBound}` and `${upperBound}` must be numeric. Both are inclusive.
  ///
  /// ---
  ///
  /// ***Facet filters***
  ///
  /// Format: `${facetName}:${facetValue}`
  /// Example: `category:Book`
  ///
  /// Facet matching is not case sensitive.
  ///
  /// When $`{facetName}` contains string values, it needs to be declared inside attributesForFaceting
  ///
  /// ---
  ///
  ///
  /// ***Tag filters***
  ///
  /// Format: `_tags:${value} (or, alternatively, just ${value})`
  /// Example: `_tags:published`
  ///
  /// Tag matching is case sensitive.
  ///
  /// If no attribute name is specified, the filter applies to `_tags`. For example: `public OR user_42` will translate into `_tags:public OR _tags:user_42`.
  ///
  /// ---
  ///
  /// **Boolean filters**
  ///
  /// Format: `facetName:${boolean_value}`
  /// Example: `isEnabled:true`
  ///
  /// When `${facetName}` needs to be declared inside [attributesForFaceting]
  ///
  /// ---
  ///
  /// ***Boolean operators***
  ///
  /// Example:
  ///
  /// ```price < 10 AND (category:Book OR NOT category:Ebook)```
  ///
  /// Individual filters can be combined via **boolean operators**. The following operators are supported:
  ///   - `OR`: must match any of the combined conditions (disjunction)
  ///   - `AND`: must match all of the combined conditions (conjunction)
  ///   - `NOT`: negate a filter
  ///
  /// Parentheses, `(` and `)`, can be used for grouping.
  ///
  /// You cannot mix different filter categories inside a disjunction (OR). For example, `num=3 OR tag1 OR facet:value` is not allowed.
  ///
  /// You cannot negate a group of filters, only an individual filter. For example, `NOT(filter1 OR filter2)` is not allowed.
  ///
  /// For performance reasons, filter expressions are limited to a conjunction (ANDs) of disjunctions (ORs). In other words, you can have ANDs of ORs (e.g. `filter1 AND (filter2 OR filter3)`), but not ORs of ANDs (e.g. `filter1 OR (filter2 AND filter3)`).
  ///
  /// ---
  ///
  /// **Usage notes:**
  ///   - Array Attributes: Any attribute set up as an array will match the filter as soon as one of the values in the array match.
  ///   - Keywords are case-sensitive.
  ///   - When to use quotes (simple or double, depending on the language):
  ///     - If a value or attribute name contains spaces (see example).
  ///     - If a value or attribute name conflicts with a keyword (see example).
  ///     - Phrases that includes quotes, like content:'It's a wonderful day' (see example).
  ///     - Phrases that includes quotes, like attribute:'She said 'Hello World'' (see example).
  ///   - Nested attributes can be used for filtering, so authors.mainAuthor:'John Doe' is a valid filter, as long as authors.mainAuthor is declared as an attributesForFaceting.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/filters/)
  ///
  @Deprecated(
      'Use `filters(String value)` instead. This method will be deprecated from version ^1.1.0')
  AlgoliaQuery setFilters(String value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('filters'));
    return _copyWithParameters(<String, dynamic>{'filters': value});
  }

  ///
  /// **Filters**
  ///
  /// Filter the query with numeric, facet and/or tag filters.
  ///
  /// This parameter uses SQL-like syntax, where you can use boolean operators and parentheses to combine individual filters.
  ///
  /// ---
  ///
  /// ***Numeric Comparisons***
  ///
  /// Format: `${attributeName} ${operator} ${value}`
  /// Example: `price > 12.99`
  ///
  /// The `${value}` must be numeric. Supported operators are `<`, `<=`, `=`, `!=`, `>=` and `>`, with the same semantics as in virtually all programming languages.
  ///
  /// ---
  ///
  /// ***Numeric Range***
  ///
  /// Format: `${attributeName}:${lowerBound} TO ${upperBound}`
  /// Example: `price:5.99 TO 100`
  ///
  /// `${lowerBound}` and `${upperBound}` must be numeric. Both are inclusive.
  ///
  /// ---
  ///
  /// ***Facet filters***
  ///
  /// Format: `${facetName}:${facetValue}`
  /// Example: `category:Book`
  ///
  /// Facet matching is not case sensitive.
  ///
  /// When $`{facetName}` contains string values, it needs to be declared inside attributesForFaceting
  ///
  /// ---
  ///
  ///
  /// ***Tag filters***
  ///
  /// Format: `_tags:${value} (or, alternatively, just ${value})`
  /// Example: `_tags:published`
  ///
  /// Tag matching is case sensitive.
  ///
  /// If no attribute name is specified, the filter applies to `_tags`. For example: `public OR user_42` will translate into `_tags:public OR _tags:user_42`.
  ///
  /// ---
  ///
  /// **Boolean filters**
  ///
  /// Format: `facetName:${boolean_value}`
  /// Example: `isEnabled:true`
  ///
  /// When `${facetName}` needs to be declared inside [attributesForFaceting]
  ///
  /// ---
  ///
  /// ***Boolean operators***
  ///
  /// Example:
  ///
  /// ```price < 10 AND (category:Book OR NOT category:Ebook)```
  ///
  /// Individual filters can be combined via **boolean operators**. The following operators are supported:
  ///   - `OR`: must match any of the combined conditions (disjunction)
  ///   - `AND`: must match all of the combined conditions (conjunction)
  ///   - `NOT`: negate a filter
  ///
  /// Parentheses, `(` and `)`, can be used for grouping.
  ///
  /// You cannot mix different filter categories inside a disjunction (OR). For example, `num=3 OR tag1 OR facet:value` is not allowed.
  ///
  /// You cannot negate a group of filters, only an individual filter. For example, `NOT(filter1 OR filter2)` is not allowed.
  ///
  /// For performance reasons, filter expressions are limited to a conjunction (ANDs) of disjunctions (ORs). In other words, you can have ANDs of ORs (e.g. `filter1 AND (filter2 OR filter3)`), but not ORs of ANDs (e.g. `filter1 OR (filter2 AND filter3)`).
  ///
  /// ---
  ///
  /// **Usage notes:**
  ///   - Array Attributes: Any attribute set up as an array will match the filter as soon as one of the values in the array match.
  ///   - Keywords are case-sensitive.
  ///   - When to use quotes (simple or double, depending on the language):
  ///     - If a value or attribute name contains spaces (see example).
  ///     - If a value or attribute name conflicts with a keyword (see example).
  ///     - Phrases that includes quotes, like content:'It's a wonderful day' (see example).
  ///     - Phrases that includes quotes, like attribute:'She said 'Hello World'' (see example).
  ///   - Nested attributes can be used for filtering, so authors.mainAuthor:'John Doe' is a valid filter, as long as authors.mainAuthor is declared as an attributesForFaceting.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/filters/)
  ///
  AlgoliaQuery filters(String value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('filters'));
    return _copyWithParameters(<String, dynamic>{'filters': value});
  }

  ///
  /// **FacetFilters**
  ///
  /// Filter hits by facet value.
  ///
  /// Usage notes:
  ///   - **Format:** The general format for referencing a facet value is `${attributeName}:${value}`. This attribute/value combination represents a filter on a given facet value.
  ///   - **Multiple filters:** If you specify multiple filters, they are interpreted as a conjunction (AND). If you want to use a disjunction (OR), use a nested array.
  ///     - `['category:Book', 'author:John Doe']` translates as `category:Book AND author:'John Doe'`.
  ///     - `[['category:Book', 'category:Movie'], 'author:John Doe']` translates as `(category:Book OR category:Movie) AND author:'John Doe'`.
  ///   - **Negation** is supported by prefixing the value with a minus sign `(-)`, sometimes called a dash. For example: `['category:Book', 'category:-Movie']` translates as `category:Book AND NOT category:Movie`.
  ///   - **Escape characters:** On the other hand, if your facet value starts with a `-`, meaning it contains the `-`, then you can escape the character with a `\` to prevent the engine from interpreting this as a negative facet filter. For example, filtering on `category:\-Movie` will filter on all records that have a category equal to “-Movie”.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/facetFilters/)
  ///
  @Deprecated(
      'Use `facetFilter(String value)` instead. This method will be deprecated from version ^1.1.0')
  AlgoliaQuery setFacetFilter(dynamic value) {
    assert(value is String || value is List<String>,
        'value must be either String | List<String> but was found `${value.runtimeType}`');
    final facetFilters = List<dynamic>.from(_parameters['facetFilters']);
    assert(facetFilters.where((dynamic item) => value == item).isEmpty,
        'FacetFilters $value already exists in this query');
    facetFilters.add(value);
    return _copyWithParameters(<String, dynamic>{'facetFilters': facetFilters});
  }

  ///
  /// **FacetFilters**
  ///
  /// Filter hits by facet value.
  ///
  /// Usage notes:
  ///   - **Format:** The general format for referencing a facet value is `${attributeName}:${value}`. This attribute/value combination represents a filter on a given facet value.
  ///   - **Multiple filters:** If you specify multiple filters, they are interpreted as a conjunction (AND). If you want to use a disjunction (OR), use a nested array.
  ///     - `['category:Book', 'author:John Doe']` translates as `category:Book AND author:'John Doe'`.
  ///     - `[['category:Book', 'category:Movie'], 'author:John Doe']` translates as `(category:Book OR category:Movie) AND author:'John Doe'`.
  ///   - **Negation** is supported by prefixing the value with a minus sign `(-)`, sometimes called a dash. For example: `['category:Book', 'category:-Movie']` translates as `category:Book AND NOT category:Movie`.
  ///   - **Escape characters:** On the other hand, if your facet value starts with a `-`, meaning it contains the `-`, then you can escape the character with a `\` to prevent the engine from interpreting this as a negative facet filter. For example, filtering on `category:\-Movie` will filter on all records that have a category equal to “-Movie”.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/facetFilters/)
  ///
  AlgoliaQuery facetFilter(dynamic value) {
    assert(value is String || value is List<String>,
        'value must be either String | List<String> but was found `${value.runtimeType}`');
    final facetFilters = List<dynamic>.from(_parameters['facetFilters']);
    assert(facetFilters.where((dynamic item) => value == item).isEmpty,
        'FacetFilters $value already exists in this query');
    facetFilters.add(value);
    return _copyWithParameters(<String, dynamic>{'facetFilters': facetFilters});
  }

  ///
  /// **OptionalFilters**
  ///
  /// Create filters for ranking purposes, where records that match the filter are ranked highest.
  ///
  /// *Optional* filtering behaves like normal filters, meaning that it returns records that match both the query and the filters. However, ***it also returns records that do not match the filters***. The effect is on the ***ranking***: records matching the filters are ranked higher than records that do not match the filters.
  ///
  /// **Usage notes:**
  ///   - The ***boolean syntax*** is the same as `facetFilters`, except for negative syntax. If you use negative syntax, for example `categories:-Book`, it will not work; it will be transformed into `categories:Book`.
  ///   - ***Promoting results***: See how you can use `optionalFilters` to promote `filters and facets`.
  ///   - ***Ranking Formula***: This setting will only work if the Filters criterion is part of the ranking. Filters is by default part of the ranking; so if you’ve removed it, and yet wish to use option filters, you’ll need to add it back to the ranking formula.
  ///
  /// **Warning:**
  ///
  /// Optional filters are not available on legacy plans (Starter, Growth, Pro). If you are on one of these plans and want to benefit from this feature, you will need to move to a new plan. Additionally, Community, Essential, and Plus plans are limited to only one optionalFilters per query, while Business and Enterprise plans are unlimited.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/facetFilters/)
  ///
  AlgoliaQuery setOptionalFilter(String value) {
    final optionalFilters = List<String>.from(_parameters['optionalFilters']);
    assert(optionalFilters.where((String item) => value == item).isEmpty,
        'OptionalFilters $value already exists in this query');
    optionalFilters.add(value);
    return _copyWithParameters(
        <String, dynamic>{'optionalFilters': optionalFilters});
  }

  ///
  /// **NumericFilters**
  ///
  /// Filter on numeric attributes.
  ///
  /// ---
  /// ***Warning***
  ///
  /// The filters parameter provides an easier to use, SQL-like syntax. We recommend using it instead of this setting.
  ///
  /// ---
  ///
  /// ***Numeric Comparisons***
  ///
  /// Format: `${attributeName} ${operator} ${operand}`
  /// Example: `inStock > 0`.
  ///
  /// Supported operators are `<`, `<=`, `=`, `!=`, `>=` and `>`, with the same semantics as in virtually all programming languages.
  ///
  /// ***Numeric Range***
  ///
  /// Format: `${attributeName}:${lowerBound} TO ${upperBound}`
  /// Example: `price:5.99 TO 100`
  ///
  /// `${lowerBound}` and `${upperBound}` must be numeric. Both are inclusive.
  ///
  /// **Usage notes:**
  ///   - ***No boolean operators***: You cannot use boolean operators like AND and OR.
  ///   - ***Multiple filters***: If you specify multiple filters, they are interpreted as a conjunction (AND). If you want to use a disjunction (OR), use a nested array.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/numericFilters/)
  ///
  AlgoliaQuery setNumericFilter(String value) {
    final numericFilters = List<String>.from(_parameters['numericFilters']);
    assert(numericFilters.where((String item) => value == item).isEmpty,
        'NumericFilters $value already exists in this query');
    numericFilters.add(value);
    return _copyWithParameters(
        <String, dynamic>{'numericFilters': numericFilters});
  }

  ///
  /// **TagFilters**
  ///
  /// Filter hits by tags.
  ///
  /// `tagFilters` is a different way of filtering, which relies on the `_tags` attribute. It uses a simpler syntax than `filters`. You can use it when you want to do simple filtering based on tags.
  ///
  /// ---
  /// ***Warning***
  ///
  /// For more advanced filtering, we recommend the `filters` parameter instead. Filters can be placed in any attribute, at any level (deep nesting included). Tags can only be contained in a top-level _tags attribute. Additionally, Filters provide an easier to use, SQL-like syntax.
  ///
  /// ---
  ///
  ///
  /// **Usage notes:**
  ///   - ***_tags***: For this setting to work, your records need to have a `_tags` attribute.
  ///   - ***Multiple filters***: If you specify multiple tags, they are interpreted as a conjunction (AND). If you want to use a disjunction (OR), use a nested array.
  ///   - ***Negation*** is supported by prefixing the tag value with a minus sign (`-`), sometimes called a dash. For example, `['tag1', '-tag2']` translates as `tag1 AND NOT tag2`.
  ///   - ***No record count***: Tag filtering is used for filtering only. You will not get a count of records that match the filters. In this way, it is the same as using `filterOnly() in the attributesForFaceting`.
  ///
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/tagFilters/)
  ///
  AlgoliaQuery setTagFilter(String value) {
    final tagFilters = List<String>.from(_parameters['tagFilters']);
    assert(tagFilters.where((String item) => value == item).isEmpty,
        'TagFilters $value already exists in this query');
    tagFilters.add(value);
    return _copyWithParameters(<String, dynamic>{'tagFilters': tagFilters});
  }

  ///
  /// **sumOrFiltersScores**
  ///
  /// Determines how to calculate the total score for filtering.
  ///
  /// When using ***filter scoring*** to rank filtered records, you can control how scores are calculated.
  ///
  /// **Usage notes:**
  ///   - When `sumOrFiltersScores` is `false`, max score will be kept.
  ///   - When `sumOrFiltersScores` is `true`, score will be summed.
  ///   - Just to be clear: False means that the total score of a record is the ***maximum score of an individual filter***. Setting it to true changes the total score by ***adding together*** the scores of each matched filter.
  ///
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/sumOrFiltersScores/)
  ///
  AlgoliaQuery setSumOrFiltersScore(bool value) {
    assert(!_parameters.containsKey('sumOrFiltersScores'),
        'SumOrFiltersScores $value already exists in this query');
    return _copyWithParameters(<String, dynamic>{'sumOrFiltersScores': value});
  }

  ///
  /// **Facets**
  ///
  /// Facets to retrieve.
  ///
  /// The effect of this setting: For each of the retrieved facets (eg. color; size),
  /// the response will contain a list of facet values (blue, red; small, large, …)
  /// in objects matching the current query. Each value will be returned with its
  /// associated count (number of matched objects containing that value).
  ///
  /// The maximum number of facet values returned depends on the [maxValuesPerFacet]
  /// setting. The default is 100 and the max is 1000.
  ///
  /// By default, the returned values are sorted by frequency, but this can be changed
  /// to alphabetical with [sortFacetValuesBy].
  ///
  ///
  ///
  /// **Usage notes:**
  ///   - Facets must have been declared beforehand in the [attributesForFaceting] index
  ///     setting.
  ///   - Faceting does *not* filter your results. If you want to filter results, you
  ///     should use [filters].
  ///   - **Default/Empty list:** If not specified or empty, no facets are retrieved. The
  ///     special value `*` may be used to retrieve all facets.
  ///   - **Approximating facet counts:(()) If the number of hits is high, facet counts
  ///     may be approximate. The response field [exhaustiveFacetsCount] is true when the
  ///     count is exact.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/facets/)
  ///
  AlgoliaQuery setFacets(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('facets'));
    return _copyWithParameters(<String, dynamic>{'facets': value});
  }

  ///
  /// **MaxValuesPerFacet**
  ///
  /// Maximum number of facet values to return for each facet during a regular search.
  ///
  /// If you want to change the number of retrieved facet hits during a search for facet values,
  /// see [maxFacetHits].
  ///
  ///
  /// **Usage notes:**
  ///   - For performance reasons, the API enforces a hard limit of 1000 on [maxValuesPerFacet].
  ///     Any value above that limit will be interpreted as 1000.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/maxValuesPerFacet/)
  ///
  AlgoliaQuery setMaxValuesPerFacet(int value) {
    assert(!_parameters.containsKey('maxValuesPerFacet'));
    return _copyWithParameters(<String, dynamic>{'maxValuesPerFacet': value});
  }

  ///
  /// **FacetingAfterDistinct**
  ///
  /// Force faceting to be applied after de-duplication (via the Distinct setting).
  ///
  /// When using the [distinct] setting in combination with faceting, facet counts may be higher than
  /// expected. This is because the engine, by default, computes faceting before applying
  /// de-duplication (`distinct`). When [facetingAfterDistinct] is set to true, the engine calculates
  /// faceting after the de-duplication has been applied.
  ///
  ///
  /// **Usage notes:**
  ///   - You should not use `facetingAfterDistinct=true` if you don’t have the same facet values in
  ///     all records sharing the same distinct key (you would get inconsistent results).
  ///   - [facetingAfterDistinct] can only be set at query time; it can’t be added as a default
  ///     setting of the index.
  ///   - [facetingAfterDistinct] will be ignored if you also set typoTolerance to either strict or
  ///     min.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/facetingAfterDistinct/)
  ///
  AlgoliaQuery setFacetingAfterDistinct({bool enable = true}) {
    assert(!_parameters.containsKey('facetingAfterDistinct'));
    return _copyWithParameters(
        <String, dynamic>{'facetingAfterDistinct': enable});
  }

  ///
  /// **SortFacetValuesBy**
  ///
  /// Controls how facet values are sorted.
  ///
  /// When using [facets], Algolia retrieves a list of matching facet values for each faceted attribute.
  /// This parameter controls how the facet values are sorted within each faceted attribute.
  ///
  ///
  /// **Usage notes:**
  ///   - You can either sort by [count] (the default, from high to low) or [alphabetically]
  ///   - The set of returned facet values depends on the maximum number of facet values returned, which
  ///     depends on the [maxValuesPerFacet] setting. The default is 100 and the max is 1000. Therefore,
  ///     values with very low frequency could potentially not be returned.
  ///
  ///
  /// **Options:**
  ///   - **count:** Facet values are sorted by decreasing count. The count is the number of records containing
  ///     this facet value in the results of the query.
  ///   - **alpha:** Facet values are sorted in alphabetical order, ascending from A to Z. The count is the
  ///     number of records containing this facet value in the results of the query.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/sortFacetValuesBy/)
  ///
  AlgoliaQuery setSortFacetValuesBy(AlgoliaSortFacetValuesBy value) {
    assert(!_parameters.containsKey('sortFacetValuesBy'));
    return _copyWithParameters(<String, dynamic>{
      'sortFacetValuesBy':
          value.toString().substring(value.toString().indexOf('.') + 1)
    });
  }

  ///
  /// **AttributesToHighlight**
  ///
  /// List of attributes to highlight.
  ///
  /// **Usage notes:**
  ///   - **Only string values** can be highlighted. Numerics will be ignored.
  ///   - If set to null, all **searchable** attributes are highlighted (see [searchableAttributes]).
  ///   - The special value `*` may be used to highlight all attributes.
  ///
  ///
  /// **Impact on the response:**
  ///   - When highlighting is enabled, each hit in the response will contain an additional [_highlightResult object] (provided that at least one of its attributes is highlighted) with the following fields:
  ///     - `value` (string): Markup text with occurrences highlighted. The tags used for highlighting are specified via [highlightPreTag] and [highlightPostTag].
  ///     - `matchLevel` (string, enum) = {`none` | `partial` | `full`}: Indicates how well the attribute matched the search query.
  ///     - `matchedWords` (array): List of words from the query that matched the object.
  ///     - `fullyHighlighted` (boolean): Whether the entire attribute value is highlighted.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributesToHighlight/)
  ///
  AlgoliaQuery setAttributesToHighlight(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('attributesToHighlight'));
    return _copyWithParameters(
        <String, dynamic>{'attributesToHighlight': value});
  }

  ///
  /// **AttributesToSnippet**
  ///
  /// List of attributes to snippet, with an optional maximum number of words to snippet.
  ///
  /// **Usage notes:**
  ///   - The number of words can be omitted, and defaults to 10.
  ///   - If not set, no attributes are snippeted.
  ///   - The special value * may be used to snippet all attributes.
  ///
  /// **Impact on the response:**
  ///   - When snippeting is enabled, each hit in the response will contain an additional _snippetResult object (provided that at least one of its attributes is snippeted) with the following fields:
  ///     - value (string): Markup text with occurrences highlighted and optional ellipsis indicators.
  ///       The tags used for highlighting are specified via highlightPreTag and highlightPostTag.
  ///       The text used to indicate ellipsis is specified via snippetEllipsisText.
  ///     - matchLevel (string, enum) = {none | partial | full}: Indicates how well the attribute matched the search query.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/)
  ///
  AlgoliaQuery setAttributesToSnippet(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('attributesToSnippet'));
    return _copyWithParameters(<String, dynamic>{'attributesToSnippet': value});
  }

  ///
  /// **HighlightPreTag**
  ///
  /// The HTML string to insert before the highlighted parts in all highlight and snippet results.
  ///
  /// **Usage notes:**
  ///   - highlightPreTag needs to be used along with [highlightPostTag].
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/highlightPreTag/)
  ///
  AlgoliaQuery setHighlightPreTag(String value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('highlightPreTag'));
    return _copyWithParameters(<String, dynamic>{'highlightPreTag': value});
  }

  ///
  /// **HighlightPostTag**
  ///
  /// The HTML string to insert after the highlighted parts in all highlight and snippet results
  ///
  /// **Usage notes:**
  ///   - highlightPostTag needs to be used along with [highlightPreTag].
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/highlightPostTag/)
  ///
  AlgoliaQuery setHighlightPostTag(String value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('highlightPostTag'));
    return _copyWithParameters(<String, dynamic>{'highlightPostTag': value});
  }

  ///
  /// **SnippetEllipsisText**
  ///
  /// String used as an ellipsis indicator when a snippet is truncated.
  ///
  /// **Usage notes:**
  ///   - Defaults to an empty string for all accounts created before February 10th, 2016.
  ///   - Defaults to '…' (U+2026, HORIZONTAL ELLIPSIS) for accounts created after that date.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/snippetEllipsisText/)
  ///
  AlgoliaQuery setSnippetEllipsisText(String value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('snippetEllipsisText'));
    return _copyWithParameters(<String, dynamic>{'snippetEllipsisText': value});
  }

  ///
  /// **RestrictHighlightAndSnippetArrays**
  ///
  /// Restrict highlighting and snippeting to items that matched the query.
  ///
  /// **Impact on the response:**
  ///   - When false, all items are highlighted/snippeted.
  ///   - When true, only items that matched at least partially are highlighted/snippeted
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/restrictHighlightAndSnippetArrays/)
  ///
  AlgoliaQuery setRestrictHighlightAndSnippetArrays({bool enable = true}) {
    assert(!_parameters.containsKey('restrictHighlightAndSnippetArrays'));
    return _copyWithParameters(
        <String, dynamic>{'restrictHighlightAndSnippetArrays': enable});
  }

  ///
  /// **Page**
  ///
  /// Specify the page to retrieve.
  ///
  /// **Usage notes:**
  ///   - Page numbers
  ///     - Page-numbering is based on the value of hitsPerPage. If hitsPerPage=20, then page=0 will display the hits from 1 to 20, page=2 will display the hits from 41 to 60.
  ///     - Page numbers are zero-based. Therefore, in order to retrieve the 10th page, you need to set page=9.
  ///   - If you send a request for a page that does not exist, or is out-of-range (i.e. when page > nbPages), we do not return an error. Instead, we return 0 results.
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/page/)
  ///
  AlgoliaQuery setPage(int value) {
    assert(!_parameters.containsKey('page'));
    return _copyWithParameters(<String, dynamic>{'page': value});
  }

  ///
  /// **HitsPerPage**
  ///
  /// Set the number of hits per page.
  ///
  /// In most cases, page/hitsPerPage is the recommended method for pagination. Check our full discussion on pagination approaches.
  ///
  /// **Usage notes:**
  ///  -  This can be set at indexing time, as a default. And can be overridden at query time.
  ///  -  1000 is the maximum
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/hitsPerPage/)
  ///
  AlgoliaQuery setHitsPerPage(int value) {
    assert(!_parameters.containsKey('hitsPerPage'));
    return _copyWithParameters(<String, dynamic>{'hitsPerPage': value});
  }

  ///
  /// **Offset**
  ///
  /// Specify the offset of the first hit to return.
  ///
  /// Offset is the position in the dataset of a particular record. By specifying offset, you retrieve a subset of records starting with the offset value. Offset normally works with length, which determines how many records to retrieve starting from the offset.
  ///
  ///  **Usage notes:**
  ///   - Offset is zero-based: the 10th record is at offset 9.
  ///   - If you omit length, the number of records returned is equal to the hitsPerPage. In fact, using offset requires that you specify length as well; otherwise, it defaults to page-based pagination.
  ///   - If offset is specified, page is ignored.
  ///   - Usage: If you have 100 records in your result set, and you want to retrieve records 50 to 80, you will need to use offset=49 and length = 30.
  ///
  ///   **Impact on the response**
  ///     - Page-based pagination (page / hitsPerPage):
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/offset/)
  ///
  AlgoliaQuery setOffset(int value) {
    assert(!_parameters.containsKey('offset'));
    return _copyWithParameters(<String, dynamic>{'offset': value});
  }

  ///
  /// **Length**
  ///
  /// Set the number of hits to retrieve (used only with offset).
  ///
  /// Similar to hitsPerPage, but works only with offset.
  ///
  /// **Usage notes:**
  ///   - 1000 is the maximum.
  ///   - If offset is omitted, length is ignored.
  ///   - On the other hand, if you specify offset but omit length, the number of records returned is equal to the hitsPerPage. In fact, using offset requires that you specify length as well; otherwise, it defaults to page-based pagination.
  ///
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/length/)
  ///
  AlgoliaQuery setLength(int value) {
    assert(!_parameters.containsKey('length'));
    return _copyWithParameters(<String, dynamic>{'length': value});
  }

  ///
  /// **paginationLimitedTo**
  ///
  /// Set the maximum number of hits accessible via pagination.
  ///
  /// We set the maximum number of hits the pagination can possibly retrieve. For example, if set to 1000, you can’t retrieve result 1001 or higher using the pagination.
  ///
  /// Works with the page and hitsPerPage settings to establish the full pagination logic.
  ///
  /// **Usage notes:**
  ///   - This must be set at indexing time, to define a default.
  ///   - By default, this parameter is set to 1000 to guarantee good performance.
  ///   - We recommend that you keep the default value to guarantee excellent performance. Increasing the pagination limit will have a direct impact on the performance of search queries. A too high value will also make it very easy for anyone to retrieve (“scrape”) your entire dataset.
  ///
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/paginationLimitedTo/)
  ///
  @Deprecated('This method is deprecated, not part of query parameters')
  AlgoliaQuery setPaginationLimitedTo(int value) {
    assert(!_parameters.containsKey('paginationLimitedTo'));
    return this;
  }

  ///
  /// **MinWordSizeFor1Typo**
  ///
  /// Minimum number of characters a word in the query string must contain to accept matches with 1 typo.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/minWordSizefor1Typo/)
  ///
  AlgoliaQuery setMinWordSizeFor1Typo(int value) {
    assert(!_parameters.containsKey('minWordSizefor1Typo'));
    return _copyWithParameters(<String, dynamic>{'minWordSizefor1Typo': value});
  }

  ///
  /// **MinWordSizeFor2Typos**
  ///
  /// Minimum number of characters a word in the query string must contain to accept matches with 2 typos.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/minWordSizefor2Typos/)
  ///
  AlgoliaQuery setMinWordSizeFor2Typos(int value) {
    assert(!_parameters.containsKey('minWordSizefor2Typos'));
    return _copyWithParameters(
        <String, dynamic>{'minWordSizefor2Typos': value});
  }

  ///
  /// **TypoTolerance**
  ///
  /// Controls whether typo tolerance is enabled and how it is applied.
  ///
  /// **Usage notes:**
  ///   - Algolia never returns records with more than 2 typos.
  ///   - If you use getRankingInfo, you can retrieve the number of typos for each result. Note that you could see 3 typos even with only 2 mistyped letters. This is because Algolia counts a typo on the first letter as 2 typos.
  ///   - Enabling typoTolerance by setting it to true, min or strict also enables [splitting and concatenation].
  /// typoTolerance: true|false|'min'|'strict'
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/typoTolerance/)
  ///
  AlgoliaQuery setTypoTolerance(dynamic value) {
    assert(value != null);
    assert(!_parameters.containsKey('typoTolerance'));
    return _copyWithParameters(<String, dynamic>{'typoTolerance': value});
  }

  ///
  /// **AllowTyposOnNumericTokens**
  ///
  /// Whether to allow typos on numbers (“numeric tokens”) in the query string.
  /// This option can be very useful on numbers with special formatting, like serial numbers and zip codes searches.
  ///
  /// **Usage notes:**
  ///   - When false, typo tolerance is disabled on numeric tokens. For example, the query 304 will match 30450 but not 40450 (which would have been the case with typo tolerance enabled).
  ///
  /// allowTyposOnNumericTokens: true|false
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/allowTyposOnNumericTokens/)
  ///
  AlgoliaQuery setAllowTyposOnNumericTokens(bool value) {
    assert(!_parameters.containsKey('allowTyposOnNumericTokens'));
    return _copyWithParameters(
        <String, dynamic>{'allowTyposOnNumericTokens': value});
  }

  ///
  /// **DisableTypoToleranceOnAttributes**
  ///
  /// List of attributes on which you want to disable typo tolerance.
  ///
  /// **Usage notes:**
  ///   - The list must be a subset of the [searchableAttributes] index setting.
  ///   - searchableAttributes must not be empty nor null for disableTypoToleranceOnAttributes to be applied.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/disableTypoToleranceOnAttributes/)
  ///
  AlgoliaQuery setDisableTypoToleranceOnAttributes(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('disableTypoToleranceOnAttributes'));
    return _copyWithParameters(
        <String, dynamic>{'disableTypoToleranceOnAttributes': value});
  }

  ///
  /// **DisableTypoToleranceOnWords**
  ///
  /// List of words on which you want to disable typo tolerance. This also disables [splitting and concatenation] on the specified words.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/disableTypoToleranceOnWords/)
  ///
  AlgoliaQuery setDisableTypoToleranceOnWords(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('disableTypoToleranceOnWords'));
    return _copyWithParameters(
        <String, dynamic>{'disableTypoToleranceOnWords': value});
  }

  ///
  /// **SeparatorsToIndex**
  ///
  /// Control which separators are indexed.
  /// Separators are all non-alphanumeric characters except space.
  ///
  /// **Usage notes:**
  ///   - By default, separators are not indexed.
  ///   - Here is a non-exhaustive list of separators frequently used by our customers: [!#()[]{}*+-_一,:;<>?@/\^|%&~£¥$§€`''‘’“”†‡]
  ///   - The search API treats separator characters as separate words. If you search “Google+” for example, the search API considers “Google” and “+” as two separate words, and counts as a match on two words in getRankingInfo.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/separatorsToIndex/)
  ///
  @Deprecated('This method is deprecated, not part of query parameters')
  AlgoliaQuery setSeparatorsToIndex(String value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('separatorsToIndex'));
    return this;
  }

  ///
  /// **AroundLatLng**
  ///
  /// Search for entries around a central geolocation, enabling a geo search within a circular area.
  ///
  /// By defining this central point, there are three consequences:
  ///   - a radius / circle is computed automatically, based on the density of the records near the point defined by this setting
  ///   - only records that fall within the bounds of the circle are returned
  ///   - records are ranked according to the distance from the center of the circle
  ///
  /// **Usage notes:**
  ///   - With this setting, you are defining a central point of a circle, whose geo-coordinates are expressed as two floats separated by a comma.
  ///   - Note: This setting differs from [aroundLatLngViaIP], which uses the end user’s IP to determine the geo-coordinates.
  ///   - This parameter will be ignored if used along with [insideBoundingBox] or [insidePolygon]
  ///   - To control the maximum size of the radius, you would use [aroundRadius].
  ///   - To control the minimum size, you would use [minimumAroundRadius].
  ///   - The size of this radius depends on the density of the area around the central point. If there are a large number of hits close to the central point, the radius can be small. The less hits near the center, the larger the radius will be.
  ///   - Note: If the results returned are less than the number of hits per page (hitsPerPage), then the number returned will be less than the hitsPerPage. For example, if you recieve 15 results, you could still see a larger number of hits per page, such as hitsPerPage=20.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/aroundLatLng/)
  ///
  AlgoliaQuery setAroundLatLng(String value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('aroundLatLng'));
    return _copyWithParameters(<String, dynamic>{'aroundLatLng': value});
  }

  ///
  /// **AroundLatLngViaIP**
  ///
  /// Search for entries around a given location automatically computed from the requester’s IP address.
  /// By computing a central geolocation (from an IP), this has three consequences:
  ///   - a radius / circle is computed automatically, based on the density of the records near the point defined by this setting
  ///   - only records that fall within the bounds of the circle are returned
  ///   - records are ranked according to the distance from the center of the circle
  ///
  /// **Usage notes:**
  ///   - With this setting, you are using the end user’s IP to define a central axis point of a circle in geo-coordinates.
  ///   - Algolia automatically calculates the size of the circular radius around this central axis.
  ///     - To control the precise size of the radius, you would use [aroundRadius].
  ///     - To control a minimum size, you would use [minimumAroundRadius].
  ///   - If you are sending the request from your servers, you must set the X-Forwarded-For HTTP header with the front-end user’s IP address for it to be used as the basis for the computation of the search location.
  ///   - Note: This setting differs from [aroundLatLng], which allows you to specify the exact latitude and longitude of the center of the circle.
  ///   - This parameter will be ignored if used along with [insideBoundingBox] or [insidePolygon]
  ///   - We currently only support IPv4 addresses. If the end user has an IPv6 address, this parameter won’t work as intended.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/aroundLatLngViaIP/)
  ///
  AlgoliaQuery setAroundLatLngViaIP(bool value) {
    assert(!_parameters.containsKey('aroundLatLngViaIP'));
    return _copyWithParameters(<String, dynamic>{'aroundLatLngViaIP': value});
  }

  ///
  /// **AroundRadius**
  ///
  /// Define the maximum radius for a geo search (in meters).
  ///
  /// **Usage notes:**
  ///   - This setting only works within the context of a radial (circuler) geo search,
  ///     enabled by `aroundLatLngViaIP` or `aroundLatLng`.
  ///   - ***How the radius is calculated:***
  ///     - If you specify the meters of the radius (instead of `all`), then only records
  ///       that fall within the bounds of the circle (as defined by the radius) will be
  ///       returned. Additionally, the ranking of the returned hits will be based on the
  ///       distance from the central axist point.
  ///     - If you use `all`, there is no longer any filtering based on the radius. All
  ///       relevant results are returned, but the ranking is still based on the distance
  ///       from the central axis point.
  ///     - If you do not use this setting, and yet perform a radial geo search (using
  ///       `aroundLatLngViaIP` or `aroundLatLng`), the radius is automatically computed
  ///       from the density of the searched area. See also `minimumAroundRadius`, which
  ///       determines the minimum size of the radius.
  ///   - For this setting to have any effect on your ranking, the geo criterion must be
  ///     included in your ranking formula (which is the case by default).
  ///
  /// **Options:**
  ///   - `radius_in_meters`: Integer value (in meters) representing the radius around the
  ///     coordinates specified during the query.
  ///   - `all`: Disables the radius logic, allowing all results to be returned, regardless
  ///     of distance. Ranking is still based on proxiùmity to the central axis point. This
  ///     option is faster than specifying a high integer value.
  ///
  /// value must be a `int` or `'all'`
  ///
  /// `1 = 1 Meter`
  ///
  /// `Therefore for 1000 = 1 Kilometer`
  ///
  /// `'aroundRadius' => 1000` // 1km
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/aroundRadius/)
  ///
  AlgoliaQuery setAroundRadius(dynamic value) {
    assert(value != null);
    assert(!_parameters.containsKey('aroundRadius'));
    assert((value is int || (value is String && value == 'all')),
        'value must be a `int` or `"all"`');
    return _copyWithParameters(<String, dynamic>{'aroundRadius': value});
  }

  ///
  /// **AroundPrecision**
  ///
  /// Precision of geo search (in meters), to add grouping by geo location to the ranking
  /// formula.
  ///
  /// When ranking hits, geo distances are grouped into ranges of `aroundPrecision` size.
  /// All hits within the same range are considered equal with respect to the `geo` ranking
  /// parameter.
  ///
  /// For example, if you set `aroundPrecision` to `100`, any two objects lying in the range
  /// `[0, 99m]` from the searched location will be considered equal; same for `[100, 199]`,
  /// `[200, 299]`, etc.
  ///
  /// Usage notes:
  ///   - For this setting to have any effect, the [geo criterion](https://www.algolia.com/doc/guides/managing-results/must-do/custom-ranking/in-depth/ranking-criteria#geo-if-applicable)
  ///     must be included in your ranking formula (which is the case by default).
  ///
  /// `1 = 1 Meter`
  ///
  /// `Therefore for 1000 = 1 Kilometer`
  ///
  /// `'aroundPrecision' => 1000` // 1km
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/aroundPrecision/)
  ///
  AlgoliaQuery setAroundPrecision(int value) {
    assert(!_parameters.containsKey('aroundPrecision'));
    return _copyWithParameters(<String, dynamic>{'aroundPrecision': value});
  }

  ///
  /// **MinimumAroundRadius**
  ///
  /// Minimum radius (in meters) used for a geo search when `aroundRadius` is not set.
  ///
  /// When a radius is automatically generated, the area of the circle might be too
  /// small to include enough records. This setting allows you to increase the size
  /// of the circle, thus ensuring sufficient coverage.
  ///
  /// **Usage notes:**
  ///   - This setting only works within the context of a circular geo search,
  ///     enabled by `aroundLatLng` or `aroundLatLngViaIP`.
  ///   - This parameter is ignored when `aroundRadius` is set.
  ///
  /// `1 = 1 Meter`
  ///
  /// `Therefore for 1000 = 1 Kilometer`
  ///
  /// `'minimumAroundRadius' => 1000` // 1km
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/minimumAroundRadius/)
  ///
  AlgoliaQuery setMinimumAroundRadius(int value) {
    assert(!_parameters.containsKey('minimumAroundRadius'));
    return _copyWithParameters(<String, dynamic>{'minimumAroundRadius': value});
  }

  ///
  /// **InsideBoundingBox**
  ///
  /// Search inside a rectangular area (in geo coordinates).
  ///
  /// The rectangle is defined by two diagonally opposite points (hereafter `p1` and `p2`),
  /// hence by 4 floats: `p1Lat`, `p1Lng`, `p2Lat`, `p2Lng`.
  ///
  /// For example: `insideBoundingBox = [ 47.3165, 4.9665, 47.3424, 5.0201 ]`
  ///
  /// **Usage notes**
  ///   - You may specify multiple bounding boxes, in which case the search will use the
  ///     union (OR) of the rectangles. To do this, pass either:
  ///     - more than 4 values (must be a multiple of 4: 8, 12…); example:
  ///       `47.3165,4.9665,47.3424,5.0201,40.9234,2.1185,38.6430,1.9916`; or
  ///     - an list of lists of floats (each inner array must contain exactly 4 values);
  ///       example: `[[47.3165, 4.9665, 47.3424, 5.0201], [40.9234, 2.1185, 38.6430, 1.9916]]`.
  ///   - [aroundLatLng] and [aroundLatLngViaIP] will be ignored if used along with this
  ///     parameter.
  ///   - Be careful when your coordinates cross over the `180th meridian`.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/insideBoundingBox/)
  ///
  AlgoliaQuery setInsideBoundingBox(List<BoundingBox> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('insideBoundingBox'));
    var list = value.map((v) => [v.p1Lat, v.p1Lng, v.p2Lat, v.p2Lng]).toList();
    return _copyWithParameters(<String, dynamic>{'insideBoundingBox': list});
  }

  ///
  /// **InsidePolygon**
  ///
  /// Search inside a rectangular area (in geo coordinates).
  ///
  /// ***A polygon***
  ///
  /// is an unlimited series of points, with a minimum of 3.
  ///
  /// A point is a set of 2 floats: latitude, longitude.
  ///
  /// The polygon therefore needs an even number of float values: `p1Lat`, `p1Lng`, `p2Lat`, `p2Lng`,
  /// `p3Lat`, `p3Long`.
  ///
  /// For example: insidePolygon=47.3165,4.9665,47.3424,5.0201,47.32,4.98
  ///
  /// **Usage notes:**
  ///   - You can plot points that are 1 meter apart or 1000s of meters apart. This all depends on the
  ///     oddness of the shape and its geographical size.
  ///   - ***multiple polygons***
  ///     You may specify multiple polygons, in which case the search will use the union (OR) of the
  ///     polygons. To specify multiple polygons, pass an list of lists of floats (each inner array must
  ///     contain an even number of values, with a minimum of 6); example:
  ///     `[[47.3165, 4.9665, 47.3424, 5.0201, 47.32, 4.9], [40.9234, 2.1185, 38.6430, 1.9916, 39.2587, 2.0104]]`.
  ///   - Keep in mind the purpose of this setting. For example, if you are drawing a circle, you will
  ///     use instead aroundRadius. If a rectangle, then insideBoundingBox. And so on.
  ///   - aroundLatLng and aroundLatLngViaIP will be ignored if used along with this parameter.
  ///   - Be careful when your coordinates cross over the `180th meridian`.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/insidePolygon/)
  ///
  AlgoliaQuery setInsidePolygon(List<BoundingPolygonBox> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('insidePolygon'));
    var list = value
        .map((v) => [v.p1Lat, v.p1Lng, v.p2Lat, v.p2Lng, v.p3Lat, v.p3Lng])
        .toList();
    return _copyWithParameters(<String, dynamic>{'insidePolygon': list});
  }

  ///
  /// **IgnorePlurals**
  ///
  /// Treats singular, plurals, and other forms of declensions as matching terms.
  ///
  /// The ignore plurals functionality (explained here in depth) considers the following forms as equivalent - that is, they match even if they are spelled differently:
  ///   - singular forms
  ///   - plural forms
  ///   - any inflected forms due to declensions (for languages where it applies)
  /// For example, “car” and “cars”, or “foot” and “feet”, are considered equivalent.
  ///
  /// **Usage notes**
  ///   - ignorePlurals is used in conjunction with the queryLanguages setting.
  ///   - You can send ignorePlurals one of 3 values:
  ///     - true, which enables the ignore plurals functionality, where singulars and plurals are considered equivalent (foot = feet). The languages supported here are either every language (this is the default, see list of languages below), or those set by queryLanguages.
  ///     - false, which disables ignore plurals, where singulars and plurals are not considered the same for matching purposes (foot will not find feet).
  ///     - a list of language ISO codes for which ignoring plurals should be enabled. This list will override any values that you may have set in queryLanguages.
  ///   - For optimum relevance, it is highly recommended that you enable only languages that are used in your data.
  ///   - List of supported languages with their associated language ISO code:
  ///
  ///      Afrikaans=af    Arabic=ar     Azerbaijani=az    Bulgarian=bg    Bengali=bn     Catalan=ca    Czech=cs        Welsh=cy
  ///         Danish=da       German=de     Greek=el          English=en      Esperanto=eo   Spanish=es    Estonian=et     Basque=eu
  ///         Persian (Farsi)=fa            Finnish=fi        Faroese=fo      French=fr      Irish=ga      Galician=gl     Hebrew=he
  ///         Hindi=hi        Hungarian=hu  Armenian=hy       Indonesian=id   Icelandic=is   Italian=it    Japanese=ja     Georgian=ka
  ///         Kazakh=kk       Korean=ko     Kurdish=ku        Kirghiz=ky      Lithuanian=lt  Latvian=lv    Maori=mi        Mongolian=mn
  ///         Marathi=mr      Malay=ms      Maltese=mt        Norwegian Bokmål=nb            Dutch=nl      Norwegian=no    Northern Sotho=ns
  ///         Polish=pl       Pashto=ps     Portuguese=pt     Brazilian=pt-br                Quechua=qu    Romanian=ro     Russian=ru
  ///         Slovak=sk       Albanian=sq   Swedish=sv        Swahili=sw     Tamil=ta        Telugu=te     Thai=th         Tagalog=tl
  ///         Tswana=tn       Turkish=tr    Tatar=tt          Ukranian=uk    Urdu=ur         Uzbek=uz      Chinese=zh
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/ignorePlurals/)
  ///
  AlgoliaQuery setIgnorePlurals(dynamic value) {
    assert(value != null, 'value can not be empty');
    assert(!_parameters.containsKey('ignorePlurals'),
        '[ignorePlurals] can not be called multiple times.');
    assert(((value is bool) || (value is List<String>)),
        'value must be true|false|["language ISO code", ...]; but value found was `${value.runtimeType}`');
    return _copyWithParameters(<String, dynamic>{'ignorePlurals': value});
  }

  ///
  /// **RemoveStopWords**
  ///
  /// Removes stop (common) words from the query before executing it
  ///
  /// Stop word removal is useful when you have a query in natural language,
  /// e.g. “what is a record?”. In that case, the engine will remove “what”, “is”, and “a” before executing the query,
  /// and therefore just search for “record”. This will remove false positives caused by stop words, especially when combined with optional words (see optionalWords and removeWordsIfNoResults).
  ///
  /// **Usage notes**
  ///   - removeStopWords is used in conjunction with the queryLanguages setting.
  ///   - You can send removeStopWords one of 3 values:
  ///       - true, which enables the stop word functionality, ensuring that stop words are removed from consideration in a search. The languages supported here are either every language (this is the default, see list of languages below), or those set by queryLanguages. See queryLanguages example below.
  ///       - false, which disables stop word functionality, allowing stop words to be taken into account in a search.
  ///       - a list of language ISO codes for which stop words should be enabled. This list will override any values that you may have set in ‘queryLanguages`.
  ///   - For most use cases, however, it is better not to use this feature, as people tend to search by keywords on search engines (that is, they naturally omit stop words).
  ///   - Prefix logic: Stop words only apply on query words that are not interpreted as prefixes. To control how prefixes are interpreted, check out queryType.
  ///
  ///   - List of supported languages with their associated language ISO code:
  ///
  ///      Afrikaans=af    Arabic=ar     Azerbaijani=az    Bulgarian=bg    Bengali=bn     Catalan=ca    Czech=cs        Welsh=cy
  ///         Danish=da       German=de     Greek=el          English=en      Esperanto=eo   Spanish=es    Estonian=et     Basque=eu
  ///         Persian (Farsi)=fa            Finnish=fi        Faroese=fo      French=fr      Irish=ga      Galician=gl     Hebrew=he
  ///         Hindi=hi        Hungarian=hu  Armenian=hy       Indonesian=id   Icelandic=is   Italian=it    Japanese=ja     Georgian=ka
  ///         Kazakh=kk       Korean=ko     Kurdish=ku        Kirghiz=ky      Lithuanian=lt  Latvian=lv    Maori=mi        Mongolian=mn
  ///         Marathi=mr      Malay=ms      Maltese=mt        Norwegian Bokmål=nb            Dutch=nl      Norwegian=no    Northern Sotho=ns
  ///         Polish=pl       Pashto=ps     Portuguese=pt     Brazilian=pt-br                Quechua=qu    Romanian=ro     Russian=ru
  ///         Slovak=sk       Albanian=sq   Swedish=sv        Swahili=sw     Tamil=ta        Telugu=te     Thai=th         Tagalog=tl
  ///         Tswana=tn       Turkish=tr    Tatar=tt          Ukranian=uk    Urdu=ur         Uzbek=uz      Chinese=zh
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/removeStopWords/)
  ///
  AlgoliaQuery setRemoveStopWords(dynamic value) {
    assert(value != null, 'value can not be empty');
    assert(!_parameters.containsKey('removeStopWords'),
        '[removeStopWords] can not be called multiple times.');
    assert(((value is bool) || (value is List<String>)),
        'value must be true|false|["language ISO code", ...]; but value found was `${value.runtimeType}`');
    return _copyWithParameters(<String, dynamic>{'removeStopWords': value});
  }

  ///
  /// **CamelCaseAttributes**
  ///
  /// List of attributes on which to do a decomposition of camel case words.
  ///
  /// Camel case compounds are basically words glued together, and being able to find a camel case compound when searching for one of its words often makes sense. This setting automatically splits camel case compounds into separate words and allows for example to find 'camelCaseAttributes' when searching for 'case'.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/camelCaseAttributes/)
  ///
  AlgoliaQuery setCamelCaseAttributes(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('camelCaseAttributes'));
    return _copyWithParameters(<String, dynamic>{'camelCaseAttributes': value});
  }

  ///
  /// **decompoundedAttributes**
  ///
  /// Specify on which attributes in your index Algolia should apply word segmentation, also known as decompounding.
  ///
  /// A compound word refers to a word that is formed by combining smaller words without spacing.
  ///
  /// They’re called noun phrases, or nominal groups, and are particularly present in Germanic and Scandinavian languages.
  /// An example is the German “Gartenstühle,” which is a contraction of “Garten” and “Stühle.”
  ///
  /// The goal of decompounding, regarding the previous example, is to index both “Garten” and “Stühle” separately, instead of together as a
  /// single word. This way, if a user searches for “Stühle”, Algolia returns results with “Gartenstühle” and other “Stühle”,
  /// for example “Polsterstühle”, “Bürostühle”, etc.
  ///
  /// **Usage notes:**
  ///   - You can specify different attributes for each language.
  ///   - As of today, the setting supports only six languages: Dutch (nl), German (de), Finnish (fi), Danish (da), Swedish (sv) and Norwegian Bokmål (no).
  ///   - Note The attributes listed must have been defined by [searchableAttributes].
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/decompoundedAttributes/)
  ///
  AlgoliaQuery setDecompoundedAttributes(dynamic value) {
    assert(value != null, 'value can not be empty');
    assert(!_parameters.containsKey('decompoundedAttributes'));
    return _copyWithParameters(
        <String, dynamic>{'decompoundedAttributes': value});
  }

  ///
  /// **KeepDiacriticsOnCharacters**
  ///
  /// List of characters that the engine shouldn’t automatically normalize.
  ///
  /// By default, the Algolia search engine normalizes all characters to their lowercase counterpart, and strips them from their diacritics.
  /// For example, 'é' becomes 'e', 'ø' becomes 'o', 'で' becomes 'て', and so on. This default behavior can be an issue for certain languages.
  /// This setting lets you disable automatic normalization on a given set of characters.
  ///
  /// **Usage notes:**
  ///   - The setting only accepts lowercase characters, but also applies to their uppercase counterpart.
  ///     For example, 'Ø' is an invalid value for this setting, but specifying 'ø' prevents the normalization of both 'ø' and 'Ø'.
  ///   - The setting only accepts characters that would be transformed otherwise. For example, 'o' is considered invalid because it doesn’t have any diacritic.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/keepDiacriticsOnCharacters/)
  ///
  AlgoliaQuery setkeepDiacriticsOnCharacters(String value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('decompoundedAttributes'));
    return _copyWithParameters(
        <String, dynamic>{'decompoundedAttributes': value});
  }

  ///
  /// **QueryLanguages**
  ///
  /// Sets the languages to be used by language-specific settings and functionalities such as [ignorePlurals], [removeStopWords], and [CJK word-detection].
  ///
  /// queryLanguages performs 2 roles:
  ///   - It sets a default list of languages used by removeStopWords and ignorePlurals (if they are enabled). For example, if you enable ignorePlurals, the languages set in queryLanguages will be applied.
  ///   - It sets the dictionary for word-detecting in CJK languages (=Chinese “zh”, Japanese “ja”, or Korean “ko”). For this, you need to place the CJK language first in queryLanguages’s list of languages. For example, to ensure that Chinese word-recognition is based on a Chinese dictionary, and not the general algorithm used for all languages, you need to place Chinese in the first position of the list of languages. Likewise for Japanese and Korean, they need to be first in the list to ensure proper dictionary-based parsing.///
  ///  **Usage notes:**
  ///   - When working with Japanese data, you also need to set “ja” in the [indexLanguages] parameter.
  ///   - If you do not use queryLanguages, the engine will use either the system default (all languages) or the list of languages specified directly in [ignorePlurals] and [removeStopWords].
  ///   - As already noted, queryLanguages creates a default list of languages. This default that can be overridden by any setting that uses the default. For example, if you set the default to English and French, you can set ignorePlurals to use the default but set removeStopWords to recognize only English stop words.
  ///   - For optimum relevance, it is recommended to only enable languages that are used in your data.
  ///   - List of supported languages with their associated language ISO code:
  ///
  ///         Afrikaans=af    Arabic=ar     Azerbaijani=az    Bulgarian=bg    Bengali=bn     Catalan=ca    Czech=cs        Welsh=cy
  ///         Danish=da       German=de     Greek=el          English=en      Esperanto=eo   Spanish=es    Estonian=et     Basque=eu
  ///         Persian (Farsi)=fa            Finnish=fi        Faroese=fo      French=fr      Irish=ga      Galician=gl     Hebrew=he
  ///         Hindi=hi        Hungarian=hu  Armenian=hy       Indonesian=id   Icelandic=is   Italian=it    Japanese=ja     Georgian=ka
  ///         Kazakh=kk       Korean=ko     Kurdish=ku        Kirghiz=ky      Lithuanian=lt  Latvian=lv    Maori=mi        Mongolian=mn
  ///         Marathi=mr      Malay=ms      Maltese=mt        Norwegian Bokmål=nb            Dutch=nl      Norwegian=no    Northern Sotho=ns
  ///         Polish=pl       Pashto=ps     Portuguese=pt     Brazilian=pt-br                Quechua=qu    Romanian=ro     Russian=ru
  ///         Slovak=sk       Albanian=sq   Swedish=sv        Swahili=sw     Tamil=ta        Telugu=te     Thai=th         Tagalog=tl
  ///         Tswana=tn       Turkish=tr    Tatar=tt          Ukranian=uk    Urdu=ur         Uzbek=uz      Chinese=zh
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/queryLanguages/)
  ///
  AlgoliaQuery setQueryLanguages(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('queryLanguages'));
    return _copyWithParameters(<String, dynamic>{'queryLanguages': value});
  }

  ///
  /// **IndexLanguages**
  ///
  /// Sets the languages at the index level for language-specific processing such as tokenization and normalization.
  /// At indexing time, the parameter sets the dictionary and algorithms for word-detecting in the provided language. At the moment, the only supported language is Japanese. Setting “ja” enables typo-tolerance in Japanese and improves the relevance when indexing documents with long attributes.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/indexLanguages/)
  ///
  AlgoliaQuery setIndexLanguages(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('indexLanguages'));
    return _copyWithParameters(<String, dynamic>{'indexLanguages': value});
  }

  ///
  /// **NaturalLanguages**
  ///
  /// This parameter changes the default values of certain parameters and settings that work best for a natural language query, such as [ignorePlurals], [removeStopWords], [removeWordsIfNoResults], [analyticsTags] and [ruleContexts].
  /// These parameters and settings work well together when the query is formatted in natural language instead of keywords, for example when your user performs a voice search.
  ///
  /// The naturalLanguages parameter changes the following parameters and setttings:
  ///   - removeStopWords and ignorePlurals are set to the given list of languages.
  ///   - removeWordsIfNoResults is set allOptional.
  ///   - It adds the natural_language value to ruleContexts.
  ///   - It adds the natural_language value to analyticsTags.
  ///
  ///  **Usage notes:**
  ///   - For optimal relevance, we recommend to only pass languages that occur in your data.
  ///   - List of supported languages with their associated language ISO code:
  ///
  ///         Afrikaans=af    Arabic=ar     Azerbaijani=az    Bulgarian=bg    Bengali=bn     Catalan=ca    Czech=cs        Welsh=cy
  ///         Danish=da       German=de     Greek=el          English=en      Esperanto=eo   Spanish=es    Estonian=et     Basque=eu
  ///         Persian (Farsi)=fa            Finnish=fi        Faroese=fo      French=fr      Irish=ga      Galician=gl     Hebrew=he
  ///         Hindi=hi        Hungarian=hu  Armenian=hy       Indonesian=id   Icelandic=is   Italian=it    Japanese=ja     Georgian=ka
  ///         Kazakh=kk       Korean=ko     Kurdish=ku        Kirghiz=ky      Lithuanian=lt  Latvian=lv    Maori=mi        Mongolian=mn
  ///         Marathi=mr      Malay=ms      Maltese=mt        Norwegian Bokmål=nb            Dutch=nl      Norwegian=no    Northern Sotho=ns
  ///         Polish=pl       Pashto=ps     Portuguese=pt     Brazilian=pt-br                Quechua=qu    Romanian=ro     Russian=ru
  ///         Slovak=sk       Albanian=sq   Swedish=sv        Swahili=sw     Tamil=ta        Telugu=te     Thai=th         Tagalog=tl
  ///         Tswana=tn       Turkish=tr    Tatar=tt          Ukranian=uk    Urdu=ur         Uzbek=uz      Chinese=zh
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/naturalLanguages/)
  ///
  AlgoliaQuery setNaturalLanguages(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('naturalLanguages'));
    return _copyWithParameters(<String, dynamic>{'naturalLanguages': value});
  }

  ///
  /// **EnableRules**
  ///
  /// Whether Rules should be globally enabled.
  ///
  /// This is a global switch that affects all Rules.
  ///
  /// **Usage notes:**
  /// - When true, Rules processing is enabled: Rules may match the query.
  /// - When false, Rules processing is disabled: no Rule will match the query.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/enableRules/)
  ///
  AlgoliaQuery setEnableRules({bool enabled = false}) {
    assert(!_parameters.containsKey('enableRules'));
    return _copyWithParameters(<String, dynamic>{'enableRules': enabled});
  }

  ///
  /// **FilterPromotes**
  ///
  /// Whether promoted results should match the filters of the current search, except for geographic filters.
  ///
  /// This is a global switch that affects all Rules.
  ///
  /// **Usage notes:**
  /// - When true, promoted results will be restricted to match the filters of the current search, except for geographic filters.
  /// - When false, the promoted results will show up regardless of the filters.
  /// - This parameter only applies to non-geographic filters; ie. geographic filters are ignored and promoted hits may not match them.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/filterPromotes/)
  ///
  AlgoliaQuery setFilterPromotes({bool enabled = false}) {
    assert(!_parameters.containsKey('filterPromotes'));
    return _copyWithParameters(<String, dynamic>{'filterPromotes': enabled});
  }

  ///
  /// **RuleContexts**
  ///
  /// Enables contextual rules.
  ///
  /// Provides a list of contexts for which rules are enabled. Contextual rules matching any of these contexts are activated, as well as generic rules.
  ///
  /// **Usage notes:**
  /// - When empty, only generic rules are activated.
  /// - For performance reasons, you may pass up to 10 different contexts to the API at a time at query time.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/ruleContexts/)
  ///
  AlgoliaQuery setRuleContexts(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('ruleContexts'));
    return _copyWithParameters(<String, dynamic>{'ruleContexts': value});
  }

  ///
  /// **EnablePersonalization**
  ///
  /// Enable the Personalization feature.
  ///
  /// The effect of setting enablePersonalization to true is to take into account user insights to personalize the ranking of records.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/enablePersonalization/)
  ///
  AlgoliaQuery setEnablePersonalization({bool enabled = false}) {
    assert(!_parameters.containsKey('enablePersonalization'));
    return _copyWithParameters(
        <String, dynamic>{'enablePersonalization': enabled});
  }

  ///
  /// **PersonalizationImpact**
  ///
  /// Define the impact of the Personalization feature.
  ///
  /// The personalizationImpact parameter sets the percentage of the impact that personalization has on ranking records.
  ///
  /// This is set at query time and therefore overrides any impact value you had set on your index. The higher the personalizationImpact, the more the results are personalized for the user, and the less the custom ranking is taken into account in ranking records.
  ///
  /// **Usage notes:**
  /// - The value must be between 0 and 100 (inclusive).
  /// - This parameter isn’t taken into account if enablePersonalization is false.
  /// - Setting personalizationImpact to 0 disables the Personalization feature, as if enablePersonalization were false.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/personalizationImpact/)
  ///
  AlgoliaQuery setPersonalizationImpact({required int value}) {
    assert(!_parameters.containsKey('personalizationImpact'));
    return _copyWithParameters(
        <String, dynamic>{'personalizationImpact': value});
  }

  ///
  /// **UserToken**
  ///
  /// Associates a certain user token with the current search.
  ///
  /// Sending a user token will associate a search with a certain user. The insights taken from this could be used in combination with personalization for example. The user token has to be an alpha-numeric string with a maximum amount of 64 characters.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/userToken/)
  ///
  AlgoliaQuery setUserToken(String value) {
    assert(!_parameters.containsKey('userToken'));
    return _copyWithParameters(<String, dynamic>{'userToken': value});
  }

  ///
  /// **QueryType**
  ///
  /// Controls if and how query words are interpreted as prefixes.
  ///
  /// **Options:**
  ///   - prefixLast: Only the last word is interpreted as a prefix (default behavior).
  ///   - prefixAll: All query words are interpreted as prefixes. This option is not recommended, as it tends to yield counterintuitive results and has a negative impact on performance.
  ///   - prefixNone: No query word is interpreted as a prefix. This option is not recommended, especially in an instant search setup, as the user will have to type the entire word(s) before getting any relevant results.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/queryType/)
  ///
  AlgoliaQuery setQueryType(QueryType value) {
    assert(!_parameters.containsKey('queryType'));
    return _copyWithParameters(
        <String, dynamic>{'queryType': value.toString().split('.').last});
  }

  ///
  /// **RemoveWordsIfNoResults**
  ///
  /// Selects a strategy to remove words from the query when it doesn’t match any hits.
  ///
  /// The goal is to avoid empty results by progressively loosening the query until hits are matched.
  /// You can learn more about this technique, as well as caveats with non-alphanumeric characters, in our in-depth guide on removing words to improve results.
  ///
  /// **Options:**
  ///   - none: No specific processing is done when a query does not return any results (default behavior).
  ///   - lastWords: When a query does not return any results, treat the last word as optional. The process is repeated with words N-1, N-2, etc. until there are results, or at most 5 words have been removed.
  ///   - firstWords: When a query does not return any results, treat the first word as optional. The process is repeated with words 2, 3, etc. until there are results, or at most 5 words have been removed.
  ///   - allOptional: When a query does not return any results, make a second attempt treating all words as optional. This is equivalent to transforming the implicit AND operator applied between query words to an OR.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/removeWordsIfNoResults/)
  ///
  AlgoliaQuery setRemoveWordsIfNoResults(RemoveWordsIfNoResults value) {
    assert(!_parameters.containsKey('removeWordsIfNoResults'));
    return _copyWithParameters(<String, dynamic>{
      'removeWordsIfNoResults': value.toString().split('.').last
    });
  }

  ///
  /// **AdvancedSyntax**
  ///
  /// Enables the advanced query syntax.
  ///
  /// This advanced syntax brings two additional features:
  ///   - Phrase query: a specific sequence of terms that must be matched next to one another.
  ///                   A phrase query needs to be surrounded by double quotes (').
  ///                   For example, the query 'search engine' only returns a record if it contains “search engine” exactly in at least one attribute.
  ///
  ///   - Note: Typo tolerance is disabled inside the phrase (i.e. within the quotes).
  ///
  ///   - Prohibit operator: excludes records that contain a specific term.
  ///                        To exclude a term, you need to prefix it with a minus (-).
  ///                        The engine only interprets the minus (-) as a prohibit operator when you place it at the start of a word.
  ///                        A minus (-) within double quotes (') is not treated as a prohibit operator.
  ///
  /// **Some examples:**
  ///   - [search -engine] only matches records containing “search”, but not “engine”.
  ///   - [search-engine] matches records containing “search” and “engine” (there’s no exclusion because the minus (-) is in the middle of the word)
  ///   - search matches every record except those containing “search”
  ///   - search engine matches records containing “engine”, but not “search”
  ///   - '-engine' matches records containing “-engine” (no exclusion performed)
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/advancedSyntax/)
  ///
  AlgoliaQuery setAdvancedSyntax({bool enabled = false}) {
    assert(!_parameters.containsKey('advancedSyntax'));
    return _copyWithParameters(<String, dynamic>{'advancedSyntax': enabled});
  }

  ///
  /// **optionalWords**
  ///
  /// A list of words that should be considered as optional when found in the query.
  ///
  /// Normally, in order for a record to match it must match all words in the query.
  /// By creating a list of optional words, you are also matching records that match only some of the words.
  ///
  /// This impacts ranking as follows:
  ///   - records that match all words are ranked higher
  ///   - records that match only some words are ranked lower
  ///
  /// **Usage notes:**
  /// - This invariably leads to a larger response.
  /// - This is a strategy to improve a response with little or no results.
  /// - You don’t need to put commas between words. Each string will automatically be tokenized into words, all of which will be considered as optional.
  /// - This parameter is often used in the context of empty or insufficient results.
  ///
  /// **Caveat**
  ///
  ///   - If a query is four or more words AND all its words are optional, the default behavior of optionalWords changes.
  ///     - The number of matched words needed for an object to be returned increases every time 1000 objects are found.
  ///     - If optionalWords contains less than 10 optional words, the number of matched words required for a result increments by one.
  ///     - From 10 optional words onwards, the number of matched words required increments by the number of optional words divided by 5 (rounded down).
  ///       For example, for an 18 word query with all words optional, the number of matched words needed goes up by 3 for every 1000 results returned.
  ///       (results 1-1000 require only one word, results 1001-2000 need four matched words, etc).
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/optionalWords/)
  ///
  AlgoliaQuery setOptionalWords(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('optionalWords'));
    return _copyWithParameters(<String, dynamic>{'optionalWords': value});
  }

  ///
  /// **DisablePrefixOnAttributes**
  ///
  /// List of attributes on which you want to disable prefix matching.
  ///
  /// This setting is useful on attributes that contain strings that should not be matched as a prefix (for example a product SKU).
  /// By creating a list of optional words, you are also matching records that match only some of the words.
  ///
  /// **Usage notes:**
  /// - The list must be a subset of the [searchableAttributes] index setting.
  /// - searchableAttributes must not be empty nor null for disablePrefixOnAttributes to be applied.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/disablePrefixOnAttributes/)
  ///
  AlgoliaQuery setDisablePrefixOnAttributes(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('disablePrefixOnAttributes'));
    return _copyWithParameters(
        <String, dynamic>{'disablePrefixOnAttributes': value});
  }

  ///
  /// **DisableExactOnAttributes**
  ///
  /// List of attributes on which you want to disable the exact ranking criterion.
  ///
  /// **Usage notes:**
  /// - The list must be a subset of the [searchableAttributes] index setting.
  /// - searchableAttributes must not be empty nor null for disableExactOnAttributes to be applied.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/disableExactOnAttributes/)
  ///
  AlgoliaQuery setDisableExactOnAttributes(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('disableExactOnAttributes'));
    return _copyWithParameters(
        <String, dynamic>{'disableExactOnAttributes': value});
  }

  ///
  /// **ExactOnSingleWordQuery**
  ///
  /// Controls how the exact ranking criterion is computed when the query contains only one word.
  ///
  /// **Usage notes:**
  /// - If exactOnSingleWordQuery is set to word, only exact matches will be highlighted in the _highlightResult property of the search response: partials and prefixes will not be.
  /// - searchableAttributes must not be empty nor null for disableExactOnAttributes to be applied.
  ///
  /// **Options**
  ///   - attribute: (default): The exact ranking criterion is set to 1 if the query matches exactly an entire attribute value.
  ///             - For example, if you search for the TV show “Road”, and in your dataset you have 2 records, “Road” and “Road Trip”,
  ///               only the record with “Road” is considered exact.
  ///   - none: The exact ranking criterion is ignored on single word queries.
  ///   - word: The exact ranking criterion is set to 1 if the query word is found in the record.
  ///           The query word must be at least 3 characters long and must not be a stop word in any supported language.
  ///             -  Continuing with our “Road” TV show example, in this case, both “Road” and “Road Trip” are considered to match exactly.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/exactOnSingleWordQuery/)
  ///
  AlgoliaQuery setExactOnSingleWordQuery(ExactOnSingleWordQuery value) {
    assert(!_parameters.containsKey('exactOnSingleWordQuery'));
    return _copyWithParameters(<String, dynamic>{
      'exactOnSingleWordQuery': value.toString().split('.').last
    });
  }

  ///
  /// **NumericAttributesForFiltering**
  ///
  /// List of numeric attributes that can be used as numerical filters.
  ///
  /// By default, all numeric attributes are automatically indexed and available as numerical filters.
  /// For faster indexing, it is best to reduce the number of numeric attributes used for filtering. This setting enables you to do
  ///
  /// **Usage notes:**
  ///   - Acceptable values:
  ///     - If a list of attributes is specified, only those attributes listed are available as numerical filters.
  ///     - If you provide an empty list, no numerical filters are allowed.
  ///     - If you specify the setting with null, then all numeric attributes are filterable. Use this to reset filtering back to all.
  ///
  /// **Modifiers**
  ///   - equalOnly: If you only need to filter on a numeric value based on equality (i.e. with the operators = or !=), you can use this modifier. All other operators will be disabled.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/numericAttributesForFiltering/)
  ///
  AlgoliaQuery setNumericAttributesForFiltering({required List<String> value}) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('numericAttributesForFiltering'));
    return _copyWithParameters(
        <String, dynamic>{'numericAttributesForFiltering': value});
  }

  ///
  /// **AllowCompressionOfIntegerArray**
  ///
  /// Enables compression of large integer arrays.
  ///
  /// In data-intensive use-cases, we recommended enabling this feature to reach a better compression ratio on arrays exclusively containing non-negative integers (as is typical of lists of user IDs or ACLs).
  ///
  /// **Usage notes:**
  ///   - When enabled, the compressed integer arrays may be reordered. Non-compressed arrays are left intact.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/allowCompressionOfIntegerArray/)
  ///
  AlgoliaQuery setAllowCompressionOfIntegerArray({bool enabled = false}) {
    assert(!_parameters.containsKey('allowCompressionOfIntegerArray'));
    return _copyWithParameters(
        <String, dynamic>{'allowCompressionOfIntegerArray': enabled});
  }

  ///
  /// **attributeForDistinct**
  ///
  /// Name of the de-duplication attribute to be used with the distinct feature
  ///
  /// **Usage notes:**
  ///   - You can define only one attribute for distinct.
  ///   - It must be done at indexing time; it cannot be defined or overridden at query time.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributeForDistinct/)
  ///
  AlgoliaQuery setAttributeForDistinct(String value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('attributeForDistinct'));
    return _copyWithParameters(
        <String, dynamic>{'attributeForDistinct': value});
  }

  ///
  /// **distinct**
  ///
  /// Enables de-duplication or grouping of results.
  ///
  /// Distinct functionality is based on one attribute, as defined in [attributeForDistinct]. Using this attribute, you can limit the number of returned records that contain the same value in that attribute.
  ///
  /// For example, if the distinct attribute is show_name and several hits (episodes) have the same value for show_name (for example “game of thrones”).
  ///   - if distinct is set to 1 (de-duplication) :
  ///       - then only the most relevant episode is kept (with respect to the ranking formula); the others are not returned. The direct effect of this is to remove redundant records from your results.
  ///   - if distinct is set to N > 1 (grouping):
  ///       - then the N most relevant episodes for every show are kept, with similar consequences.
  ///
  /// **Usage notes:**
  ///   - For this setting to work, you need to set the distinct attribute in [attributeForDistinct].
  ///   - When set to 1, you enable de-duplication, in which only the most relevant result is returned for all records that have the same value in the distinct attribute. This is similar to the SQL distinct keyword.
  ///   - When set to N (where N > 1), you enable grouping, in which most N hits will be returned with the same value for the distinct attribute.
  ///   - If no distinct attribute is configured, distinct will be accepted at query time but silently ignored.
  ///   - A 0 value disables de-duplication and grouping.
  ///   - When using grouping (when distinct > 1):
  ///       - the hitsPerPage parameter controls the number of groups that are returned. In the case of jobs and associated companies, if hitsPerPage=10 and distinct=3, up to 30 records will be returned - 10 companies and at most 3 jobs per company. This behavior makes it easy to implement pagination with grouping.
  ///       - the nbHits attribute in the response contains the number of groups.
  ///   - [Keep in mind]
  ///       - Distinct is a computationally expensive operation on large data sets, especially if distinct > 1
  ///       - distinct(true) is the same as distinct(1)
  ///       - distinct(false) is the same as distinct(0), which is the same thing as not specifying distinct at all
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/distinct/)
  ///
  AlgoliaQuery setDistinct({dynamic value = 0}) {
    assert(value is int || value is bool, 'value should be a int or boolean');
    assert(!_parameters.containsKey('distinct'));
    return _copyWithParameters(<String, dynamic>{'distinct': value});
  }

  ///
  /// **getRankingInfo**
  ///
  /// Retrieve detailed ranking information.
  ///
  /// This setting lets you see exactly which ranking criteria played a role in selecting each record.
  ///
  /// **Impact on the response:**
  ///   - When true, each hit in the response contains an additional _rankingInfo object, which contains the following fields, all at the same level.
  ///     - Textual relevance / Ranking
  ///       - nbTypos (integer): Number of typos encountered when matching the record. Corresponds to the typos ranking criterion in the ranking formula.
  ///       - firstMatchedWord (integer): Contains 2 pieces of information - the searchable attribute that best matched the query and the character position within that attribute.
  ///           - To determine which attribute within the list of searchableAttributes was the best match, you need to divide the number by 1000: (int) (firstMatchedWord / 1000). For example, if firstMatchedWord=2001, (int) (2001/1000)=2, the best matching attribute is the 3rd one in the list of searchableAttributes (2 = position 3).
  ///           - To calculate the character position within the best matching attribute, you need to extract the remainder of the division using the modulo function of your programming language, such as firstMatchedWord % 1000. For example, if firstMatchedWord=2001, (2001 % 1000)=1, the match began at the 2nd position within the best matching attribute (1 = position 2). Recall that character position only concerns unorderd attributes. For ordered attributes, firstMatchedWord will always be an even thousand (0, 1000, 2000, etc), that is, there will be no remainder. This is because the position of the match does not matter in the ranking, algolia will always consider it to be in the first position. For more on searchable attributes modifiers
  ///       - proximityDistance (integer): The sum of the distances between matched words when the query contains more than one word. Corresponds to the proximity criterion in the ranking formula.
  ///       - userScore (integer): Custom ranking for the object, expressed as a single numerical value. This field is internal to Algolia and shouldn’t be relied upon.
  ///       - nbExactWords (integer): Number of exactly matched words. If alternativesAsExact is set, it may include plurals and/or synonyms.
  ///       - words (integer): Number of matched words in the query, including prefixes and typos.
  ///       - filters (integer): This field is reserved for advanced usage. It will be zero in most cases.
  ///       - promoted (boolean): Present and set to true if a Rule promoted the hit.
  ///
  ///     - Geo search (see how these are used)
  ///       - geoDistance (integer): Distance between the geo location in the search query and the best matching geo location in the record, divided by the geo precision.
  ///       - geoPrecision (integer): Precision used when computed the geo distance, in meters. All distances will be floored to a multiple of this precision.
  ///       - matchedGeoLocation (array): Contains the latitude, longitude, and distance (in meters) from a central axis point.
  ///
  ///     - Additional information
  ///       - serverUsed (string): Actual host name of the server that processed the request. (Our DNS supports automatic failover and load balancing, so this may differ from the host name used in the request.)
  ///       - indexUsed (string): Index name used for the query. In case of A/B testing, the index returned here is the one that was actually used, either index A (the target) or B (the variant).
  ///       - abTestID (integer): In case of A/B testing, returns the ID of the A/B test.
  ///       - abTestVariantID (integer): In case of A/B testing, returns the ID of the variant used. The variant ID is the position in the array of variants (starting at 1).
  ///       - parsedQuery (string): The query string that will be searched, after normalization. Normalization includes removing stop words (if removeStopWords is enabled), and transforming portions of the query string into phrase queries (see advancedSyntax).
  ///       - timeoutCounts (boolean): Whether a timeout was hit when computing the facet counts. When true, the counts will be interpolated (i.e. approximate). See also exhaustiveFacetsCount.
  ///       - timeoutHits (boolean): Whether a timeout was hit when retrieving the hits. When true, some results may be missing.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/getRankingInfo/)
  ///
  AlgoliaQuery setGetRankingInfo({bool enabled = true}) {
    assert(!_parameters.containsKey('getRankingInfo'));
    return _copyWithParameters(<String, dynamic>{'getRankingInfo': enabled});
  }

  ///
  /// **clickAnalytics**
  ///
  /// Enable the Click Analytics feature.
  ///
  /// The effect of setting clickAnalytics to true is to add a queryID to the search response.
  /// As explained here, this queryID can subsequently be used in click and conversion analytics.
  ///
  /// **Usage notes:**
  ///   - This parameter does not, on its own, add any new analytics data; it only ensures that a queryID is returned. With that queryID, it will be up to you then to choose the best events to send as clicks and conversions. Learn more in our guide on implementing analytics.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/clickAnalytics/)
  ///
  AlgoliaQuery setClickAnalytics({bool enabled = false}) {
    assert(!_parameters.containsKey('clickAnalytics'));
    return _copyWithParameters(<String, dynamic>{'clickAnalytics': enabled});
  }

  ///
  /// **Analytics**
  ///
  /// Whether the current query will be taken into account in the Analytics.
  ///
  /// **Usage notes:**
  ///   - Algolia captures analytics on every search. This is the default setting. Therefore, this setting’s primary use is to turn analytics off for a given query.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/analytics/)
  ///
  AlgoliaQuery setAnalytics({bool enabled = false}) {
    assert(!_parameters.containsKey('analytics'));
    return _copyWithParameters(<String, dynamic>{'analytics': enabled});
  }

  ///
  /// **AnalyticsTags**
  ///
  /// List of tags to apply to the query for analytics purposes.
  ///
  /// You can use tags in analytics to filter searches. For example, you can send two different tags - mobile and website - to see how mobile users search in comparison to website users.
  ///
  /// There are a couple of limitations to keep in mind when sending analytics tags:
  ///   - Tags can be up to 100 characters long. Longer tags are ignored.
  ///   - Tags starting with alg# are reserved for internal usage and are ignored.
  ///   - A query has a maximum of 10 unique tags. Extra tags are ignored.
  ///   - A maximum of 3,500 unique tags combinations is processed per 5-minute window. All extra tags are ignored. A tags combination is the list of tags found in a query. For example, sending 3 queries, each respectively tagged with platform:ios, lang:en, and platform:ios,lang:en, counts as 3 combinations.
  ///
  /// **Usage notes:**
  ///   - Algolia captures analytics on every search. This is the default setting. Therefore, this setting’s primary use is to turn analytics off for a given query.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/analyticsTags/)
  ///
  AlgoliaQuery setAnalyticsTags(List<String> value) {
    assert(value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('analyticsTags'));
    return _copyWithParameters(<String, dynamic>{'analyticsTags': value});
  }

  ///
  /// **Synonyms**
  ///
  /// Whether to take into account an index’s synonyms for a particular search.
  ///
  /// This setting overrides the default query behavior, which is to use all defined synonyms on every search. By setting this to false, you are disabling synonyms for the given query. True is the engine default.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/synonyms/)
  ///
  AlgoliaQuery setSynonyms({bool enabled = false}) {
    assert(!_parameters.containsKey('synonyms'));
    return _copyWithParameters(<String, dynamic>{'synonyms': enabled});
  }

  ///
  /// **ReplaceSynonymsInHighlight**
  ///
  /// Whether to highlight and snippet the original word that matches the synonym or the synonym itself.
  ///
  /// For example, let’s say you set up home as a synonym for house, and the user types home.
  /// Synonym logic will match any record that contains ‘house’ with the synonym ‘home’.
  /// This setting will replace the word ‘house’ with ‘home’ in the response.
  /// The effect of this is that all highlighting and snippeting will be on the synonym ‘home’.
  /// Without this setting, the original word ‘house’ would have been returned and highlighted and snippeted.
  ///
  /// **Usage notes:**
  ///   - [When true], highlighting and snippeting will use words from the query rather than the original words from the objects.
  ///   - [When false], highlighting and snippeting will always display the original words from the objects.
  ///   - Multiple words can be replaced by a one-word synonym, but not the other way round.
  ///     For example, if “NYC” and “New York City” are synonyms, searching for “NYC” will replace “New York City” with “NYC” in highlights and snippets, but searching for “New York City” will not replace “NYC” with “New York City” in highlights and snippets.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/replaceSynonymsInHighlight/)
  ///
  AlgoliaQuery setReplaceSynonymsInHighlight({bool enabled = false}) {
    assert(!_parameters.containsKey('replaceSynonymsInHighlight'));
    return _copyWithParameters(
        <String, dynamic>{'replaceSynonymsInHighlight': enabled});
  }

  ///
  /// **MaxFacetHits**
  ///
  /// Maximum number of facet hits to return during a search for facet values.
  ///
  /// If you want to change the number of retrieved facet values for a regular search, see maxValuesPerFacet.
  ///
  /// **Usage notes:**
  ///   - Does not apply to regular search queries.
  ///   - For performance reasons, the maximum allowed number of returned values is 100. Any value outside the range [1, 100] will be rejected.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/maxFacetHits/)
  ///
  AlgoliaQuery setMaxFacetHits(int value) {
    assert(!_parameters.containsKey('maxFacetHits'));
    return _copyWithParameters(<String, dynamic>{'maxFacetHits': value});
  }

  ///
  /// **PercentileComputation**
  ///
  /// Whether to include or exclude a query from the processing-time percentile computation.
  ///
  /// **Usage notes:**
  ///   - When true, the API saves the processing time of the search query and includes it when computing the 90% and 99% percentiles, available in your Algolia dashboard.
  ///   - When false, the search query is excluded from the percentile computation.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/percentileComputation/)
  ///
  AlgoliaQuery setPercentileComputation({bool enabled = false}) {
    assert(!_parameters.containsKey('percentileComputation'));
    return _copyWithParameters(
        <String, dynamic>{'percentileComputation': enabled});
  }

  ///
  /// **AttributeCriteriaComputedByMinProximity**
  ///
  /// When attribute is ranked above proximity in your ranking formula, proximity is used to select which searchable attribute is matched in the attribute ranking stage.
  ///
  /// **Usage notes:**
  ///   - This parameter can only impact relevance when attribute comes before proximity in the ranking formula. By default, this isn’t the case. The rationale for ranking proximity above attribute is detailed in the ranking criteria section. Generally, for objects with long text sections and a clear searchable attribute order (like documentation), it can be beneficial to rank by attribute before proximity.
  ///   - attributeCriteriaComputedByMinProximity works in the following way: By default, searches that match multiple searchable attributes are ranked by their best matching attribute (depending on searchable attributes order). However, if you set this parameter to true, the matched attribute is selected based on minimum proximity. In other words, if a search query matches on an object in multiple, different searchable attributes, the one with the smallest proximity is selected.
  ///   - For example, consider an index of books, where you have set your searchable attributes to title, author, and description (in that order), and where you’ve changed the ranking formula so that attribute comes before proximity. If the search for a book matches on both its title, with a proximity of 6, and description, with a proximity of 1, then title remains the best matching attribute even though description has a better proximity score. Setting attributeCriteriaComputedByMinProximity to true computes the best matching attribute based on minimum proximity; in our case, description is used instead of title.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributeCriteriaComputedByMinProximity/)
  ///
  AlgoliaQuery setAttributeCriteriaComputedByMinProximity(
      {bool enabled = false}) {
    assert(!_parameters.containsKey('attributeCriteriaComputedByMinProximity'));
    return _copyWithParameters(
        <String, dynamic>{'attributeCriteriaComputedByMinProximity': enabled});
  }

  ///
  /// **EnableABTest**
  ///
  /// Whether this search should participate in running AB tests.
  ///
  /// **Usage notes:**
  ///   - By default, a search participates in currently active AB tests. You can prevent this by setting the enableABTest parameter to false.
  ///     You may want to do this for searches performed in closed environments (like administration panels), or for searches that must target specific index variants during testing or development.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/enableABTest/)
  ///
  AlgoliaQuery setEnableABTest({bool enabled = false}) {
    assert(!_parameters.containsKey('enableABTest'));
    return _copyWithParameters(<String, dynamic>{'enableABTest': enabled});
  }
}

class BoundingBox {
  BoundingBox({
    required this.p1Lat,
    required this.p1Lng,
    required this.p2Lat,
    required this.p2Lng,
  });

  num p1Lat;
  num p1Lng;
  num p2Lat;
  num p2Lng;
}

class BoundingPolygonBox {
  BoundingPolygonBox({
    required this.p1Lat,
    required this.p1Lng,
    required this.p2Lat,
    required this.p2Lng,
    required this.p3Lat,
    required this.p3Lng,
  });

  num p1Lat;
  num p1Lng;
  num p2Lat;
  num p2Lng;
  num p3Lat;
  num p3Lng;
}

enum QueryType {
  prefixLast,
  prefixAll,
  prefixNone,
}

enum RemoveWordsIfNoResults {
  none,
  lastWords,
  firstWords,
  allOptional,
}

enum ExactOnSingleWordQuery {
  attribute,
  none,
  word,
}
