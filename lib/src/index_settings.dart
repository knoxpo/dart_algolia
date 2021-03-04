part of algolia;

///
/// **AlgoliaIndexSettings**
///
/// A AlgoliaIndexSettings object can be used to get setting instance,
/// peform references, manage the index and querying for objects (using
/// the methods inherited from [AlgoliaSettings]).
///
class AlgoliaIndexSettings extends AlgoliaSettings {
  const AlgoliaIndexSettings._(
    Algolia algolia,
    String indexName, {
    Map<String, dynamic> parameters,
  })  : assert(indexName != null && indexName != '*',
            'Index Name is required, but was found: $indexName'),
        super._(algolia, indexName);

  Future<Map<String, dynamic>> getSettings() async {
    try {
      String url = '${algolia._host}indexes/$_index/settings';
      Response response = await get(
        Uri.parse(url),
        headers: algolia._header,
      );
      Map<String, dynamic> body = json.decode(response.body);
      return body;
    } catch (err) {
      return err;
    }
  }
}

class AlgoliaSettings {
  const AlgoliaSettings._(
    this.algolia,
    String indexName, {
    final Map<String, dynamic> parameters,
  })  : assert(indexName != null && indexName != '*',
            'Index Name is required, but was found: $indexName'),
        this._index = indexName,
        _parameters = parameters ?? const <String, dynamic>{};

  final Algolia algolia;
  final String _index;
  final Map<String, dynamic> _parameters;

  AlgoliaSettings _copyWithParameters(Map<String, dynamic> parameters) {
    return AlgoliaSettings._(
      algolia,
      _index,
      parameters: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(_parameters)..addAll(parameters),
      ),
    );
  }

  Future<AlgoliaTask> setSettings() async {
    try {
      assert(
          _parameters.keys.isNotEmpty, 'No setting parameter to update found.');

      String url = '${algolia._host}indexes/$_index/settings';
      Response response = await put(
        Uri.parse(url),
        headers: algolia._header,
        body: utf8
            .encode(json.encode(_parameters, toEncodable: jsonEncodeHelper)),
        encoding: Encoding.getByName('utf-8'),
      );
      Map<String, dynamic> body = json.decode(response.body);
      AlgoliaTask task = AlgoliaTask._(algolia, _index, body);
      return task;
    } catch (err) {
      return err;
    }
  }

  ///
  /// **SearchableAttributes (Attributes)**
  ///
  /// TODO: documentation to be added
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/searchableAttributes/)
  ///
  AlgoliaSettings setSearchableAttributes(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('searchableAttributes'));
    return _copyWithParameters(
        <String, dynamic>{'searchableAttributes': value});
  }

  ///
  /// **AttributesForFaceting (Attributes)**
  ///
  /// TODO: documentation to be added
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributesForFaceting/)
  ///
  AlgoliaSettings setAttributesForFaceting(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('attributesForFaceting'));
    return _copyWithParameters(
        <String, dynamic>{'attributesForFaceting': value});
  }

  ///
  /// **UnretrievableAttributes (Attributes)**
  ///
  /// TODO: documentation to be added
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/unretrievableAttributes/)
  ///
  AlgoliaSettings setUnretrievableAttributes(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('unretrievableAttributes'));
    return _copyWithParameters(
        <String, dynamic>{'unretrievableAttributes': value});
  }

  ///
  /// **AttributesToRetrieve (Attributes)**
  ///
  /// TODO: documentation to be added
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributesToRetrieve/)
  ///
  AlgoliaSettings setAttributesToRetrieve(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('attributesToRetrieve'));
    return _copyWithParameters(
        <String, dynamic>{'attributesToRetrieve': value});
  }

  ///
  /// **Ranking (Ranking)**
  ///
  /// TODO: documentation to be added
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/ranking/)
  ///
  AlgoliaSettings setRanking(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('ranking'));
    return _copyWithParameters(<String, dynamic>{'ranking': value});
  }

  ///
  /// **CustomRanking (Ranking)**
  ///
  /// TODO: documentation to be added
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/customRanking/)
  ///
  AlgoliaSettings setCustomRanking(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('customRanking'));
    return _copyWithParameters(<String, dynamic>{'customRanking': value});
  }

  ///
  /// **Replicas (Ranking)**
  ///
  /// TODO: documentation to be added
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/replicas/)
  ///
  AlgoliaSettings setReplicas(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('replicas'));
    return _copyWithParameters(<String, dynamic>{'replicas': value});
  }

  ///
  /// **MaxValuesPerFacet (Faceting)**
  ///
  /// TODO: documentation to be added
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/maxValuesPerFacet/)
  ///
  AlgoliaSettings setMaxValuesPerFacet(int value) {
    assert(value != null);
    assert(!_parameters.containsKey('maxValuesPerFacet'));
    return _copyWithParameters(<String, dynamic>{'maxValuesPerFacet': value});
  }

  ///
  /// **SortFacetValuesBy (Faceting)**
  ///
  /// TODO: documentation to be added
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/sortFacetValuesBy/)
  ///
  AlgoliaSettings setSortFacetValuesBy(int value) {
    assert(value != null);
    assert(!_parameters.containsKey('sortFacetValuesBy'));
    return _copyWithParameters(<String, dynamic>{'sortFacetValuesBy': value});
  }

  ///
  /// **AttributesToHighlight (Highlighting-Snippeting)**
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
  AlgoliaSettings setAttributesToHighlight(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('attributesToHighlight'));
    return _copyWithParameters(
        <String, dynamic>{'attributesToHighlight': value});
  }

  ///
  /// **AttributesToSnippet (Highlighting-Snippeting)**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/)
  ///
  AlgoliaSettings setAttributesToSnippet(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('attributesToSnippet'));
    return _copyWithParameters(<String, dynamic>{'attributesToSnippet': value});
  }

  ///
  /// **AttributesToSnippet (Highlighting-Snippeting)**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/)
  ///
  AlgoliaSettings setHighlightPreTag(String value) {
    assert(value != null);
    assert(!_parameters.containsKey('highlightPreTag'));
    return _copyWithParameters(<String, dynamic>{'highlightPreTag': value});
  }

  ///
  /// **AttributesToSnippet (Highlighting-Snippeting)**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/attributesToSnippet/)
  ///
  AlgoliaSettings setHighlightPostTag(String value) {
    assert(value != null);
    assert(!_parameters.containsKey('highlightPostTag'));
    return _copyWithParameters(<String, dynamic>{'highlightPostTag': value});
  }

  ///
  /// **SnippetEllipsisText (Highlighting-Snippeting)**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/snippetEllipsisText/)
  ///
  AlgoliaSettings setSnippetEllipsisText(String value) {
    assert(value != null);
    assert(!_parameters.containsKey('snippetEllipsisText'));
    return _copyWithParameters(<String, dynamic>{'snippetEllipsisText': value});
  }

  ///
  /// **RestrictHighlightAndSnippetArrays (Highlighting-Snippeting)**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/restrictHighlightAndSnippetArrays/)
  ///
  AlgoliaSettings setRestrictHighlightAndSnippetArrays({bool enable = true}) {
    assert(enable != null);
    assert(!_parameters.containsKey('restrictHighlightAndSnippetArrays'));
    return _copyWithParameters(
        <String, dynamic>{'restrictHighlightAndSnippetArrays': enable});
  }

  ///
  /// **HitsPerPage (Pagination)**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/hitsPerPage/)
  ///
  AlgoliaSettings setHitsPerPage(int value) {
    assert(value != null);
    assert(!_parameters.containsKey('hitsPerPage'));
    return _copyWithParameters(<String, dynamic>{'hitsPerPage': value});
  }

  ///
  /// **PaginationLimitedTo (Pagination)**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/paginationLimitedTo/)
  ///
  AlgoliaSettings setPaginationLimitedTo(int value) {
    assert(value != null);
    assert(!_parameters.containsKey('paginationLimitedTo'));
    return _copyWithParameters(<String, dynamic>{'paginationLimitedTo': value});
  }

  ///
  /// **MinWordSizeFor1Typo (Typos)**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/minWordSizefor1Typo/)
  ///
  AlgoliaSettings setMinWordSizeFor1Typo(int value) {
    assert(value != null);
    assert(!_parameters.containsKey('minWordSizefor1Typo'));
    return _copyWithParameters(<String, dynamic>{'minWordSizefor1Typo': value});
  }

  ///
  /// **MinWordSizeFor2Typos (Typos)**
  ///
  /// TODO: Documentation to be added.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/minWordSizefor2Typos/)
  ///
  AlgoliaSettings setMinWordSizeFor2Typos(int value) {
    assert(value != null);
    assert(!_parameters.containsKey('minWordSizefor2Typos'));
    return _copyWithParameters(
        <String, dynamic>{'minWordSizefor2Typos': value});
  }

  ///
  /// **TypoTolerance (Typos)**
  ///
  /// TODO: Documentation to be added.
  ///
  /// typoTolerance: true|false|'min'|'strict'
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/typoTolerance/)
  ///
  AlgoliaSettings setTypoTolerance(dynamic value) {
    assert(value != null);
    assert(!_parameters.containsKey('typoTolerance'));
    return _copyWithParameters(<String, dynamic>{'typoTolerance': value});
  }

  ///
  /// **AllowTyposOnNumericTokens (Typos)**
  ///
  /// TODO: Documentation to be added.
  ///
  /// allowTyposOnNumericTokens: true|false
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/allowTyposOnNumericTokens/)
  ///
  AlgoliaSettings setAllowTyposOnNumericTokens(bool value) {
    assert(value != null);
    assert(!_parameters.containsKey('allowTyposOnNumericTokens'));
    return _copyWithParameters(
        <String, dynamic>{'allowTyposOnNumericTokens': value});
  }

  ///
  /// **DisableTypoToleranceOnAttributes (Typos)**
  ///
  /// TODO: Documentation to be added.
  ///
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/disableTypoToleranceOnAttributes/)
  ///
  AlgoliaSettings setDisableTypoToleranceOnAttributes(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('disableTypoToleranceOnAttributes'));
    return _copyWithParameters(
        <String, dynamic>{'disableTypoToleranceOnAttributes': value});
  }

  //
  // **DisableTypoToleranceOnWords (Typos)**
  //
  // TODO: Documentation to be added.
  //
  //
  // Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/disableTypoToleranceOnWords/)
  //
  AlgoliaSettings setDisableTypoToleranceOnWords(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('disableTypoToleranceOnWords'));
    return _copyWithParameters(
        <String, dynamic>{'disableTypoToleranceOnWords': value});
  }

  //
  // **SeparatorsToIndex (Typos)**
  //
  // TODO: Documentation to be added.
  //
  //
  // Source: [Learn more](https://www.algolia.com/doc/api-reference/api-parameters/separatorsToIndex/)
  //
  AlgoliaSettings setSeparatorsToIndex(List<String> value) {
    assert(value != null);
    assert(!_parameters.containsKey('separatorsToIndex'));
    return _copyWithParameters(<String, dynamic>{'separatorsToIndex': value});
  }
}
