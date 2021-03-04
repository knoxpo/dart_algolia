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
      {@required this.algolia,
      @required String index,
      Map<String, dynamic> parameters})
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
            }),
        assert(algolia != null),
        assert(index != null);
  final Algolia algolia;
  final String _index;
  final Map<String, dynamic> _parameters;

  Map<String, dynamic> get parameters => _parameters;

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
    String url = '${algolia._host}indexes/$_index/query';
    Response response = await post(
      Uri.parse(url),
      headers: algolia._header,
      body:
          utf8.encode(json.encode(_parameters, toEncodable: jsonEncodeHelper)),
      encoding: Encoding.getByName('utf-8'),
    );
    Map<String, dynamic> body = json.decode(response.body);
    return AlgoliaQuerySnapshot.fromMap(algolia, _index, body);
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
  AlgoliaQuery search(String value) {
    assert(value != null);
    assert(!_parameters.containsKey('search'));
    return _copyWithParameters(<String, dynamic>{'query': value});
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
    assert(value != null);
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
    assert(value != null);
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
  ///     - Phrases that includes quotes, like content:"It's a wonderful day" (see example).
  ///     - Phrases that includes quotes, like attribute:"She said "Hello World"" (see example).
  ///   - Nested attributes can be used for filtering, so authors.mainAuthor:"John Doe" is a valid filter, as long as authors.mainAuthor is declared as an attributesForFaceting.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/filters/)
  ///
  AlgoliaQuery setFilters(String value) {
    assert(value != null);
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
  ///     - `["category:Book", "author:John Doe"]` translates as `category:Book AND author:"John Doe"`.
  ///     - `[["category:Book", "category:Movie"], "author:John Doe"]` translates as `(category:Book OR category:Movie) AND author:"John Doe"`.
  ///   - **Negation** is supported by prefixing the value with a minus sign `(-)`, sometimes called a dash. For example: `["category:Book", "category:-Movie"]` translates as `category:Book AND NOT category:Movie`.
  ///   - **Escape characters:** On the other hand, if your facet value starts with a `-`, meaning it contains the `-`, then you can escape the character with a `\` to prevent the engine from interpreting this as a negative facet filter. For example, filtering on `category:\-Movie` will filter on all records that have a category equal to “-Movie”.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/facetFilters/)
  ///
  AlgoliaQuery setFacetFilter(dynamic value) {
    assert(value is String || value is List<String>,
        'value must be either String | List<String> but was found `${value.runtimeType}`');
    final List<dynamic> facetFilters =
        List<dynamic>.from(_parameters['facetFilters']);
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
    final List<String> optionalFilters =
        List<String>.from(_parameters['optionalFilters']);
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
    final List<String> numericFilters =
        List<String>.from(_parameters['numericFilters']);
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
  ///   - ***Negation*** is supported by prefixing the tag value with a minus sign (`-`), sometimes called a dash. For example, `["tag1", "-tag2"]` translates as `tag1 AND NOT tag2`.
  ///   - ***No record count***: Tag filtering is used for filtering only. You will not get a count of records that match the filters. In this way, it is the same as using `filterOnly() in the attributesForFaceting`.
  ///
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/tagFilters/)
  ///
  AlgoliaQuery setTagFilter(String value) {
    final List<String> tagFilters =
        List<String>.from(_parameters['tagFilters']);
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
    assert(value != null);
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
    assert(value != null);
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
    assert(enable != null);
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
    assert(value != null);
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
    assert(value != null);
    assert(!_parameters.containsKey('attributesToHighlight'));
    return _copyWithParameters(
        <String, dynamic>{'attributesToHighlight': value});
  }

  ///
  /// **AttributesToSnippet**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/)
  ///
  AlgoliaQuery setAttributesToSnippet(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('attributesToSnippet'));
    return _copyWithParameters(<String, dynamic>{'attributesToSnippet': value});
  }

  ///
  /// **AttributesToSnippet**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/)
  ///
  AlgoliaQuery setHighlightPreTag(String value) {
    assert(value != null);
    assert(!_parameters.containsKey('highlightPreTag'));
    return _copyWithParameters(<String, dynamic>{'highlightPreTag': value});
  }

  ///
  /// **AttributesToSnippet**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/)
  ///
  AlgoliaQuery setHighlightPostTag(String value) {
    assert(value != null);
    assert(!_parameters.containsKey('highlightPostTag'));
    return _copyWithParameters(<String, dynamic>{'highlightPostTag': value});
  }

  ///
  /// **SnippetEllipsisText**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/snippetEllipsisText/)
  ///
  AlgoliaQuery setSnippetEllipsisText(String value) {
    assert(value != null);
    assert(!_parameters.containsKey('snippetEllipsisText'));
    return _copyWithParameters(<String, dynamic>{'snippetEllipsisText': value});
  }

  ///
  /// **RestrictHighlightAndSnippetArrays**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/restrictHighlightAndSnippetArrays/)
  ///
  AlgoliaQuery setRestrictHighlightAndSnippetArrays({bool enable = true}) {
    assert(enable != null);
    assert(!_parameters.containsKey('restrictHighlightAndSnippetArrays'));
    return _copyWithParameters(
        <String, dynamic>{'restrictHighlightAndSnippetArrays': enable});
  }

  ///
  /// **Page**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/page/)
  ///
  AlgoliaQuery setPage(int value) {
    assert(value != null);
    assert(!_parameters.containsKey('page'));
    return _copyWithParameters(<String, dynamic>{'page': value});
  }

  ///
  /// **HitsPerPage**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/hitsPerPage/)
  ///
  AlgoliaQuery setHitsPerPage(int value) {
    assert(value != null);
    assert(!_parameters.containsKey('hitsPerPage'));
    return _copyWithParameters(<String, dynamic>{'hitsPerPage': value});
  }

  ///
  /// **Offset**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/offset/)
  ///
  AlgoliaQuery setOffset(int value) {
    assert(value != null);
    assert(!_parameters.containsKey('offset'));
    return _copyWithParameters(<String, dynamic>{'offset': value});
  }

  ///
  /// **Length**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/length/)
  ///
  AlgoliaQuery setLength(int value) {
    assert(value != null);
    assert(!_parameters.containsKey('length'));
    return _copyWithParameters(<String, dynamic>{'length': value});
  }

  ///
  /// **MinWordSizeFor1Typo**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/minWordSizefor1Typo/)
  ///
  AlgoliaQuery setMinWordSizeFor1Typo(int value) {
    assert(value != null);
    assert(!_parameters.containsKey('minWordSizefor1Typo'));
    return _copyWithParameters(<String, dynamic>{'minWordSizefor1Typo': value});
  }

  ///
  /// **MinWordSizeFor2Typos**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/minWordSizefor2Typos/)
  ///
  AlgoliaQuery setMinWordSizeFor2Typos(int value) {
    assert(value != null);
    assert(!_parameters.containsKey('minWordSizefor2Typos'));
    return _copyWithParameters(
        <String, dynamic>{'minWordSizefor2Typos': value});
  }

  ///
  /// **TypoTolerance**
  ///
  /// TODO: Documentation to be added.
  ///
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
  /// TODO: Documentation to be added.
  ///
  /// allowTyposOnNumericTokens: true|false
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/allowTyposOnNumericTokens/)
  ///
  AlgoliaQuery setAllowTyposOnNumericTokens(bool value) {
    assert(value != null);
    assert(!_parameters.containsKey('allowTyposOnNumericTokens'));
    return _copyWithParameters(
        <String, dynamic>{'allowTyposOnNumericTokens': value});
  }

  ///
  /// **DisableTypoToleranceOnAttributes**
  ///
  /// TODO: Documentation to be added.
  ///
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/disableTypoToleranceOnAttributes/)
  ///
  AlgoliaQuery setDisableTypoToleranceOnAttributes(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('disableTypoToleranceOnAttributes'));
    return _copyWithParameters(
        <String, dynamic>{'disableTypoToleranceOnAttributes': value});
  }

  ///
  /// **AroundLatLng**
  ///
  /// TODO: Documentation to be added.
  ///
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/aroundLatLng/)
  ///
  AlgoliaQuery setAroundLatLng(String value) {
    assert(value != null);
    assert(!_parameters.containsKey('aroundLatLng'));
    return _copyWithParameters(<String, dynamic>{'aroundLatLng': value});
  }

  ///
  /// **AroundLatLngViaIP**
  ///
  /// TODO: Documentation to be added.
  ///
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/aroundLatLngViaIP/)
  ///
  AlgoliaQuery setAroundLatLngViaIP(bool value) {
    assert(value != null);
    assert(!_parameters.containsKey('aroundLatLngViaIP'));
    return _copyWithParameters(
        <String, dynamic>{'aroundLatLngViaIP': value ?? false});
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
  /// value must be a `int` or `"all"`
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
    assert(value != null);
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
    assert(value != null);
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
    assert(value != null && value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('insideBoundingBox'));
    List<List<num>> list =
        value.map((v) => [v.p1Lat, v.p1Lng, v.p2Lat, v.p2Lng]).toList();
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
    assert(value != null && value.isNotEmpty, 'value can not be empty');
    assert(!_parameters.containsKey('insidePolygon'));
    List<List<num>> list = value
        .map((v) => [v.p1Lat, v.p1Lng, v.p2Lat, v.p2Lng, v.p3Lat, v.p3Lng])
        .toList();
    return _copyWithParameters(<String, dynamic>{'insidePolygon': list});
  }

  ///
  /// **attributeForDistinct**
  ///
  /// Name of the de-duplication attribute to be used with the distinct feature.
  ///
  /// TODO: Add documention.
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributeForDistinct/)
  ///
  AlgoliaQuery setAttributeForDistinct(String value) {
    assert(value != null, 'value can not be empty');
    assert(!_parameters.containsKey('attributeForDistinct'));
    return _copyWithParameters(
        <String, dynamic>{'attributeForDistinct': value});
  }

  ///
  /// **distinct**
  ///
  /// Name of the de-duplication attribute to be used with the distinct feature.
  ///
  /// TODO: Add documention.
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
  /// TODO: Add documention.
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/getRankingInfo/)
  ///
  AlgoliaQuery setGetRankingInfo({bool enabled = true}) {
    assert(enabled != null, 'value can not be empty');
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
  /// TODO: Add documention.
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/clickAnalytics/)
  ///
  AlgoliaQuery setClickAnalytics({bool enabled = false}) {
    assert(enabled != null, 'value can not be empty');
    assert(!_parameters.containsKey('clickAnalytics'));
    return _copyWithParameters(<String, dynamic>{'clickAnalytics': enabled});
  }
}

class BoundingBox {
  BoundingBox({
    @required this.p1Lat,
    @required this.p1Lng,
    @required this.p2Lat,
    @required this.p2Lng,
  });
  num p1Lat;
  num p1Lng;
  num p2Lat;
  num p2Lng;
}

class BoundingPolygonBox {
  BoundingPolygonBox({
    @required this.p1Lat,
    @required this.p1Lng,
    @required this.p2Lat,
    @required this.p2Lng,
    @required this.p3Lat,
    @required this.p3Lng,
  });
  num p1Lat;
  num p1Lng;
  num p2Lat;
  num p2Lng;
  num p3Lat;
  num p3Lng;
}
