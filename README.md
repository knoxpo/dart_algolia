# Algolia Search (Dart Client)

![Algolia](https://res.cloudinary.com/hilnmyskv/image/upload/q_auto/v1614950376/Algolia_com_Website_assets/images/shared/algolia_logo/logo-algolia-nebula-blue-full.svg 'Algolia')

**[UNOFFICIAL]** Algolia is a pure dart SDK, wrapped around Algolia REST API for easy implementation for your Flutter or Dart projects.

[![pub package](https://img.shields.io/pub/v/algolia.svg)](https://pub.dartlang.org/packages/algolia)  [![.github/workflows/dart.yml](https://github.com/knoxpo/dart_algolia/actions/workflows/dart.yml/badge.svg)](https://github.com/knoxpo/dart_algolia/actions/workflows/dart.yml) [![Build Status](https://travis-ci.com/knoxpo/dart_algolia.svg?branch=master)](https://travis-ci.com/knoxpo/dart_algolia)

[Pub](https://pub.dartlang.org/packages/algolia) - [API Docs](https://pub.dartlang.org/documentation/algolia/latest/) - [GitHub](https://github.com/knoxpo/dart_algolia)

## Features

- Query / Search / Similar Query
- Get Object
- Add Object
- Add Objects
- Replace all objects in an Index
- Update Object
- Partial Update Object
- Delete Object
- Perform Batch Activities
- Add Index
- Delete Index
- Clear Index
- Copy Index
- Move Index
- Index Settings
- Push Insights Events

## Version compatibility

See CHANGELOG for all breaking (and non-breaking) changes.

## Become Contributor

If you wish to contribute in our development process, refer to our [Contributing Guidelines](https://github.com/knoxpo/dart_algolia/blob/master/CONTRIBUTING.md)

## Getting started

You should ensure that you add the router as a dependency in your flutter project.

```yaml
dependencies:
 algolia: ^1.1.2
```

You should then run `flutter packages upgrade` or update your packages in IntelliJ.

## Example Project

There is a pretty sweet example project in the `example` folder. Check it out. Otherwise, keep reading to get up and running.

## Setting up

```dart
  ///
  /// Initiate static Algolia once in your project.
  ///
  class Application {
    static final Algolia algolia = Algolia.init(
      applicationId: 'YOUR_APPLICATION_ID',
      apiKey: 'YOUR_API_KEY',
    );
  }
  
  void main() async {
    ///
    /// Initiate Algolia in your project
    ///
    Algolia algolia = Application.algolia;

    ///
    /// Perform Query
    ///
    AlgoliaQuery query = algolia.instance.index('contacts').query('john');

    // Perform multiple facetFilters
    query = query.facetFilter('status:published');
    query = query.facetFilter('isDelete:false');

    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();

    // Checking if has [AlgoliaQuerySnapshot]
    print('Hits count: ${snap.nbHits}');

    ///
    /// Perform Index Settings
    ///
    AlgoliaIndexSettings settingsRef = algolia.instance.index('contact').settings;

    // Get Settings
    Map<String, dynamic> currentSettings = await settingsRef.getSettings();

    // Checking if has [Map]
    print('\n\n');
    print(currentSettings);

    // Set Settings
    AlgoliaSettings settingsData = settingsRef;
    settingsData = settingsData.setReplicas(const ['index_copy_1', 'index_copy_2']);
    AlgoliaTask setSettings = await settingsData.setSettings();

    // Checking if has [AlgoliaTask]
    print('\n\n');
    print(setSettings.data);

    // Pushing Event
    AlgoliaEvent event = AlgoliaEvent(
      eventType: AlgoliaEventType.view,
      eventName: 'View contact',
      index: 'contacts',
      userToken: 'user123',
    );
    await algolia.instance.pushEvents([event]);
  }
```

## Insights

The Insights API lets you push a collection of events related to how your product is being used. Sending those events is a required step for using several Algolia features like Click analytics, A/B Testing, Personalization and Dynamic Re-Ranking.

- `.pushEvents(List<AlgoliaEvent> events)`


## Search Parameters

Here is the list of parameters you can use with the search method (search scope).
We have managed to include most commonly used parameters for search functionality
and there many more to be added in future releases.

We have indicated counts of queryable parameters with their availability status
on official Algolia website and what we have managed to support it in this
version of the release.

##### search (1/1)

- `.query(String value)`
- `.similarQuery(String value)`

##### attributes (2/2)

- `.setAttributesToRetrieve(List<String> value)`
- `.setRestrictSearchableAttributes(List<String> value)`

##### filtering (6/6)

- `.filters(String value)`
- `.facetFilter(dynamic value)` This can be used multiple times in a query.
- `.setOptionalFilter(String value)` This can be used multiple times in a query.
- `.setNumericFilter(String value)` This can be used multiple times in a query.
- `.setTagFilter(String value)` This can be used multiple times in a query.
- `.setSumOrFiltersScore(bool value)`

##### faceting (4/4)

- `.setFacets(List<String> value)`
- `.setMaxValuesPerFacet(int value)`
- `.setFacetingAfterDistinct({bool enable = true})`
- `.setSortFacetValuesBy(AlgoliaSortFacetValuesBy value)`

##### highlighting-snippeting (6/6)

- `.setAttributesToHighlight(List<String> value)`
- `.setAttributesToSnippet(List<String> value)`
- `.setHighlightPreTag(String value)`
- `.setHighlightPostTag(String value)`
- `.setSnippetEllipsisText(String value)`
- `.setRestrictHighlightAndSnippetArrays({bool enable = true})`

##### pagination (4/4)

- `.setPage(int value)`
- `.setHitsPerPage(int value)`
- `.setOffset(int value)`
- `.setLength(int value)`

##### typos (5/5)

- `.setMinWordSizeFor1Typo(int value)`
- `.setMinWordSizeFor2Typos(int value)`
- `.setTypoTolerance(dynamic value)`
- `.setAllowTyposOnNumericTokens(bool value)`
- `.setDisableTypoToleranceOnAttributes(List<String> value)`

##### geo-search (7/7)

- `.setAroundLatLng(String value)`
- `.setAroundLatLngViaIP(bool value)`
- `.setAroundRadius(dynamic value)`
- `.setAroundPrecision(int value)`
- `.setMinimumAroundRadius(int value)`
- `.setInsideBoundingBox(List<BoundingBox> value)`
- `.setInsidePolygon(List<BoundingPolygonBox> value)`

##### languages (8/11)

- `.setIgnorePlurals(dynamic value)`
- `.setRemoveStopWords(dynamic value)`
- `.setCamelCaseAttributes(List<String> value)`
- `.setDecompoundedAttributes(dynamic value)`
- `.setkeepDiacriticsOnCharacters(String value)`
- `.setQueryLanguages(List<String> value)`
- `.setIndexLanguages(List<String> value)`
- `.setNaturalLanguages(List<String> value)`

##### query-rules (3/3)

- `.setEnableRules({bool enabled = false})`
- `.setFilterPromotes({bool enabled = false})`
- `.setRuleContexts(List<String> value)`

##### personalization (3/3)

- `.setEnablePersonalization({bool enabled = false})`
- `.setPersonalizationImpact({required int value})`
- `.setUserToken({required String value})`

##### query-strategy (7/7)

- `.setQueryType(QueryType value)`
- `.setRemoveWordsIfNoResults(RemoveWordsIfNoResults value)`
- `.setAdvancedSyntax({bool enabled = false})`
- `.setOptionalWords(List<String> value)`
- `.setDisablePrefixOnAttributes(List<String> value)`
- `.setDisableExactOnAttributes(List<String> value)`
- `.setExactOnSingleWordQuery(ExactOnSingleWordQuery value)`

##### performance (2/2)

- `.setNumericAttributesForFiltering({required List<String> value})`
- `.setAllowCompressionOfIntegerArray({bool enabled = false})`

##### advanced (11/15)

- `.setAttributeForDistinct(String value)`
- `.setDistinct({dynamic value = 0})`
- `.setGetRankingInfo({bool enabled = true})`
- `.setClickAnalytics({bool enabled = false})`
- `.setAnalytics({bool enabled = false})`
- `.setAnalyticsTags(List<String> value)`
- `.setSynonyms({bool enabled = false})`
- `.setReplaceSynonymsInHighlight({bool enabled = false})`
- `.setMaxFacetHits(int value)`
- `.setPercentileComputation({bool enabled = false})`
- `.setEnableABTest({bool enabled = false})`

##### custom-query (11/15)
- `.custom(String key, dynamic value)`

##### GET RESULT

- `.getObjects()`

## Settings Parameters

Here is the list of parameters you can use with the settings method (settings scope).
We have managed to include most commonly used parameters for settings functionality
and there many more to be added in future releases.

We have indicated counts of settings parameters with their availability status
on official Algolia website and what we have managed to support it in this
version of the release.

##### attributes (4/4)

- `.setSearchableAttributes(List<String> value)`
- `.setAttributesForFaceting(List<String> value)`
- `.setUnretrievableAttributes(List<String> value)`
- `.setAttributesToRetrieve(List<String> value)`

##### ranking (3/3)

- `.setRanking(List<String> value)`
- `.setCustomRanking(List<String> value)`
- `.setReplicas(List<String> value)`

##### faceting (2/2)

- `.setMaxValuesPerFacet(int value)`
- `.setSortFacetValuesBy(AlgoliaSortFacetValuesBy value)`

##### highlighting-snippeting (6/6)

- `.setAttributesToHighlight(List<String> value)`
- `.setAttributesToSnippet(List<String> value)`
- `.setHighlightPreTag(String value)`
- `.setHighlightPostTag(String value)`
- `.setSnippetEllipsisText(String value)`
- `.setRestrictHighlightAndSnippetArrays({bool enable = true})`

##### pagination (2/2)

- `.setHitsPerPage(int value)`
- `.setPaginationLimitedTo(int value)`

##### typos (7/7)

- `.setMinWordSizeFor1Typo(int value)`
- `.setMinWordSizeFor2Typos(int value)`
- `.setTypoTolerance(dynamic value)`
- `.setAllowTyposOnNumericTokens(bool value)`
- `.setDisableTypoToleranceOnAttributes(List<String> value)`
- `.setDisableTypoToleranceOnWords(List<String> value)`
- `.setSeparatorsToIndex(List<String> value)`

##### languages (8/11)

- `.setIgnorePlurals(dynamic value)`
- `.setRemoveStopWords(dynamic value)`
- `.setCamelCaseAttributes(List<String> value)`
- `.setDecompoundedAttributes(dynamic value)`
- `.setkeepDiacriticsOnCharacters(String value)`
- `.setQueryLanguages(List<String> value)`
- `.setIndexLanguages(List<String> value)`
- `.setNaturalLanguages(List<String> value)`

##### query-rules (3/3)

- `.setEnableRules({bool enabled = false})`
- `.setFilterPromotes({bool enabled = false})`
- `.setRuleContexts(List<String> value)`

##### personalization (3/3)

- `.setEnablePersonalization({bool enabled = false})`
- `.setPersonalizationImpact({required int value})`
- `.setUserToken({required String value})`

##### query-strategy (7/7)

- `.setQueryType(QueryType value)`
- `.setRemoveWordsIfNoResults(RemoveWordsIfNoResults value)`
- `.setAdvancedSyntax({bool enabled = false})`
- `.setOptionalWords(List<String> value)`
- `.setDisablePrefixOnAttributes(List<String> value)`
- `.setDisableExactOnAttributes(List<String> value)`
- `.setExactOnSingleWordQuery(ExactOnSingleWordQuery value)`

##### performance (2/2)

- `.setNumericAttributesForFiltering({required List<String> value})`
- `.setAllowCompressionOfIntegerArray({bool enabled = false})`

##### advanced (11/15)

- `.setAttributeForDistinct(String value)`
- `.setDistinct({dynamic value = 0})`
- `.setGetRankingInfo({bool enabled = true})`
- `.setClickAnalytics({bool enabled = false})`
- `.setAnalytics({bool enabled = false})`
- `.setAnalyticsTags(List<String> value)`
- `.setSynonyms({bool enabled = false})`
- `.setReplaceSynonymsInHighlight({bool enabled = false})`
- `.setMaxFacetHits(int value)`
- `.setPercentileComputation({bool enabled = false})`
- `.setEnableABTest({bool enabled = false})`

##### GET Settings

- `.getSettings()`

##### SET Settings

- `.setSettings()`

------
*Algolia [Unofficial SDK for Dart] is a Knoxpo original.*

<a href="https://knoxpo.com" target="_knoxpo"><img src="https://www.knoxpo.com/assets/logo.png" width="80"></a>
