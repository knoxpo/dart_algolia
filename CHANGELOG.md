## 1.0.2

* Added insights implementation.

```dart
// Create an Event
AlgoliaEvent event = AlgoliaEvent(
  eventType: AlgoliaEventType.view,
  eventName: 'View contact',
  index: 'contacts',
  userToken: 'user123',
);

// Push Event
await algolia.instance.pushEvents([event]);
```

* Added `queryID` to query snapshot when click analytics is enabled.
* Fixed null error in query snapshot.

## 1.0.1

* Fixed faulty assert resolved for checking empty values.
* Fixed all enum valued query and setting methods.
* Deprecated some `AlgoliaQuery` methods:
  * `search()` instead use `query()`
  * `setSimilarQuery()` instead use `similarQuery()`
  * `setFilters()` instead use `filters()`
  * `setFacetFilter()` instead use `facetFilter()`
  * `setPaginationLimitedTo()` This method is deprecated, not part of query parameters.
  * `setSeparatorsToIndex()` This method is deprecated, not part of query parameters.
* Improved stability for debugging use `.toString()` to get working variables of the interface (applicable for all Algolia classes).
* Added `.toMap()` to all data dictionary classes.

## 1.0.0+1

* Implemented `analysis_options.yaml`.

## 1.0.0

* Fixed https://github.com/knoxpo/dart_algolia/issues/26.
* Added support for null safety.
* Added _Query_ options:
  * In `similarQuery` Search
  * In `languages` 8/11
  * In `query-rules` 3/3
  * In `personalization` 3/3
  * In `query-strategy` 7/7
  * In `performance` 2/2
  * In `advanced` 11/15
* Added _Setting_ options:
  * In `languages` 8/11
  * In `query-rules` 3/3
  * In `personalization` 3/3
  * In `query-strategy` 7/7
  * In `performance` 2/2
  * In `advanced` 11/15
* Added new error handling class `AlgoliaError`.
* Bumped `http` version.

## 0.1.7

* Solved few health suggestion, to improve the health of the code.
* Added support for `facets_stats` property returned by Algolia query.

## 0.1.6+1

* Solved few health suggestion, to improve the health of the code.

## 0.1.6

* Added implementation of `multipleQueries`

```dart
AlgoliaQuery queryA = algolia.instance.index('users').search('john');
AlgoliaQuery queryB = algolia.instance.index('jobs').search('business');

// Perform multiple facetFilters
queryA = queryA.setFacetFilter('status:active');
queryA = queryA.setFacetFilter('isDelete:false');

// Perform multiple facetFilters
queryB = queryB.setFacetFilter('isDelete:false');

// Get Result/Objects
List<AlgoliaQuerySnapshot> snap =
    await algolia.multipleQueries.addQueries([queryA, queryB]).getObjects();
  ```

## 0.1.5

* [Bug] Solved a technical reported bug [#11](https://github.com/knoxpo/dart_algolia/issues/11)
* [Added] Copy, Move Index functionalities.
* [Added] PR implementation of `replaceAllObjects()`

## 0.1.4+3

* [Bug] Solved few health suggestion, to improve the health of the code.

## 0.1.4+2

* [Bug] `.setFacetFilter(dynamic value)` can now accept String or List<String> value.
* [Added] AttributeForDistinct (Advance)
* [Added] Distinct (Advance)
* [Added] GetRankingInfo (Advance)
* [Added] ClickAnalytics (Advance)

## 0.1.4+1

* Added `facets` to `AlgoliaQuerySnapshot` to list facets name with hits count.

## 0.1.3+2

* highlightResult [Bug] (commit ref: 0d76d24fe8aa347a0933920afe5ded43bdcbd68b)
* snippetResult [Implementation] (commit ref: 0d76d24fe8aa347a0933920afe5ded43bdcbd68b)

## 0.1.3+1

* Updated `example.dart`: Added index settings example.
* Updated index `.setSettings()` response to `AlgoliaTask`.

## 0.1.3

* Added support to manage index settings (Get & Set), limited to 24 settings parameters, more to be added in newer releases.

## 0.1.2

* OptionalFilter (Filtering)
* NumericFilter (Filtering)
* TagFilter (Filtering)
* SumOrFiltersScore (Filtering)
* AroundLatLng (Geo Search)
* AroundLatLngViaIP (Geo Search)
* AroundRadius (Geo Search)
* AroundPrecision (Geo Search)
* MinimumAroundRadius (Geo Search)
* InsideBoundingBox (Geo Search)
* InsidePolygon (Geo Search)
* MinWordSizefor1Typo (Typo)
* MinWordSizefor2Typos (Typo)
* TypoTolerance (Typo)
* AllowTyposOnNumericTokens (Typo)
* DisableTypoToleranceOnAttributes (Typo)
* DisableTypoToleranceOnWords (Typo)
* SeparatorsToIndex (Typo)

## 0.1.1

* Bug fixes.
* Removed Flutter direct dependency to support universal dart projects.

## 0.1.0

* Initial release.
