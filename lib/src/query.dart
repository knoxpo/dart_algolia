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
              'facetFilters': List<List<String>>.unmodifiable(<List<String>>[]),
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
    try {
      if (_parameters['attributesToRetrieve'] == null) {
        _copyWithParameters(<String, dynamic>{
          'attributesToRetrieve': const ['*']
        });
      }
      String url = '${algolia._host}indexes/$_index/query';
      Response response = await post(
        url,
        headers: algolia._header,
        body: utf8
            .encode(json.encode(_parameters, toEncodable: jsonEncodeHelper)),
        encoding: Encoding.getByName('utf-8'),
      );
      Map<String, dynamic> body = json.decode(response.body);
      return AlgoliaQuerySnapshot.fromMap(algolia, _index, body);
    } catch (err) {
      throw err;
    }
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/query/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/attributesToRetrieve/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/restrictSearchableAttributes/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/filters/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/facetFilters/)
  ///
  AlgoliaQuery setFacetFilter(String value) {
    final List<String> facetFilters =
        List<String>.from(_parameters['facetFilters']);
    assert(facetFilters.where((String item) => value == item).isEmpty,
        'FacetFilters $value already exists in this query');
    facetFilters.add(value);
    return _copyWithParameters(<String, dynamic>{'facetFilters': facetFilters});
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/facets/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/maxValuesPerFacet/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/facetingAfterDistinct/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/sortFacetValuesBy/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/attributesToHighlight/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/snippetEllipsisText/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/restrictHighlightAndSnippetArrays/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/page/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/hitsPerPage/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/offset/)
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
  /// Document Source: (https://www.algolia.com/doc/api-reference/api-parameters/length/)
  ///
  AlgoliaQuery setLength(int value) {
    assert(value != null);
    assert(!_parameters.containsKey('length'));
    return _copyWithParameters(<String, dynamic>{'length': value});
  }
}
