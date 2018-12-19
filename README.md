# Algolia
[Unofficial] Algolia pure dart SDK, wrapped around Algolia REST API for easy implementation for your Flutter or Dart projects.

[![pub package](https://img.shields.io/pub/v/algolia.svg)](https://pub.dartlang.org/packages/algolia)

[Pub](https://pub.dartlang.org/packages/algolia) - [API Docs](https://pub.dartlang.org/documentation/algolia/latest/) - [GitHub](https://github.com/knoxpo/algolia)

## Features
- Query / Search
- Get Object
- Add Object
- Update Object
- Partial Update Object
- Delete Object
- Perform Batch Activities
- Add Index
- Delete Index

## Version compatibility
See CHANGELOG for all breaking (and non-breaking) changes.

## Become Contributor
If you wish to 

## Getting started
You should ensure that you add the router as a dependency in your flutter project.
```yaml
dependencies:
 algolia: ^0.1.0
```
You should then run `flutter packages upgrade` or update your packages in IntelliJ.


## Example Project
There is a pretty sweet example project in the `example` folder. Check it out. Otherwise, keep reading to get up and running.


## Setting up
```dart
  class Application {
    static Algolia algolia = Algolia.init(
      applicationId: 'YOUR_APPLICATION_ID',
      apiKey: 'YOUR_API_KEY',
    );
  }
  
  void main() async {
    ///
    /// Initiate Algolia in your project
    ///
    Algolia algolia = Application.algolia;
    AlgoliaTask taskAdded, taskUpdated, taskDeleted, taskBatch, taskClearIndex, taskDeleteIndex;
    AlgoliaObjectSnapshot addedObject;


    ///
    /// 1. Perform Adding Object to existing Index.
    ///
    test("1. Perform Adding Object to existing Index.", () async {
      Map<String, dynamic> addData = {
        'name': 'John Smith',
        'contact': '+1 609 123456',
        'email': 'johan@example.com',
        'isDelete': false,
        'status': 'published',
        'createdAt': DateTime.now(),
        'modifiedAt': DateTime.now(),
      };
      taskAdded = await algolia.instance.index('contacts').add(addData);

      // Checking if has [AlgoliaTask]
      expect(taskAdded.runtimeType, AlgoliaTask);
      print(taskAdded.data);
    });


    ///
    /// 2. Perform Get Object to existing Index.
    ///
    /// -- A Delay of 3 seconds is added for algolia to cdn the object for retrieval.
    test("2. Perform Get Object to existing Index.", () async {
      addedObject = await Future.delayed(Duration(seconds: 3), () async {
        return await algolia.instance
            .index('contacts')
            .object(taskAdded.data['objectID'].toString())
            .getObject();
      });

      // Checking if has [AlgoliaObjectSnapshot]
      print('\n\n');
      expect(addedObject.runtimeType, AlgoliaObjectSnapshot);
      print(addedObject.data);
    });


    ///
    /// 3. Perform Updating Object to existing Index.
    ///
    test("3. Perform Updating Object to existing Index.", () async {
      Map<String, dynamic> updateData =
          Map<String, dynamic>.from(addedObject.data);
      updateData['contact'] = '+1 609 567890';
      updateData['modifiedAt'] = DateTime.now();
      taskUpdated = await algolia.instance
          .index('contacts')
          .object(addedObject.objectID)
          .updateData(updateData);

      // Checking if has [AlgoliaTask]
      print('\n\n');
      expect(taskUpdated.runtimeType, AlgoliaTask);
      print(taskUpdated.data);
    });


    ///
    /// 4. Perform Delete Object to existing Index.
    ///
    test("4. Perform Delete Object to existing Index.", () async {
      taskDeleted = await algolia.instance
          .index('contacts')
          .object(addedObject.objectID)
          .deleteObject();

      // Checking if has [AlgoliaTask]
      print('\n\n');
      expect(taskDeleted.runtimeType, AlgoliaTask);
      print(taskDeleted.data);
    });


    ///
    /// 5. Perform Batch
    ///
    test("5. Perform Batch", () async {
      AlgoliaBatch batch = algolia.instance.index('contacts').batch();
      batch.clearIndex();
      for (int i = 0; i < 10; i++) {
        Map<String, dynamic> addData = {
          'name': 'John ${DateTime.now().microsecond}',
          'contact': '+1 ${DateTime.now().microsecondsSinceEpoch}',
          'email': 'johan.${DateTime.now().microsecond}@example.com',
          'isDelete': false,
          'status': 'published',
          'createdAt': DateTime.now(),
          'modifiedAt': DateTime.now(),
        };
        batch.addObject(addData);
      }

      // Get Result/Objects
      taskBatch = await batch.commit();

      // Checking if has [AlgoliaTask]
      print('\n\n');
      expect(taskBatch.runtimeType, AlgoliaTask);
      print(taskBatch.data);
    });


    ///
    /// 6. Perform Query
    ///
    test("6. Perform Query", () async {
      AlgoliaQuery query = algolia.instance.index('contacts').search('john');

      // Perform multiple facetFilters
      query = query.setFacetFilter('status:published');
      query = query.setFacetFilter('isDelete:false');

      // Get Result/Objects
      AlgoliaQuerySnapshot snap = await query.getObjects();

      // Checking if has [AlgoliaQuerySnapshot]
      print('\n\n');
      expect(snap.runtimeType, AlgoliaQuerySnapshot);
      print('Hits count: ${snap.nbHits}');
    });


    ///
    /// 7. Perform List all Indices
    ///
    test("7. Perform List all Indices", () async {
      AlgoliaIndexesSnapshot indices = await algolia.instance.getIndices();

      // Checking if has [AlgoliaIndexesSnapshot]
      print('\n\n');
      expect(indices.runtimeType, AlgoliaIndexesSnapshot);
      print('Indices count: ${indices.items.length}');
    });


    ///
    /// 8. Perform Clear Index.
    ///
    test("8. Perform Clear Index.", () async {
      taskClearIndex = await algolia.instance.index('contacts').clearIndex();

      // Checking if has [AlgoliaTask]
      print('\n\n');
      expect(taskClearIndex.runtimeType, AlgoliaTask);
      print(taskClearIndex.data);
    });


    ///
    /// 9. Perform Delete Index.
    ///
    test("9. Perform Delete Index.", () async {
      taskDeleteIndex = await algolia.instance.index('contact').deleteIndex();

      // Checking if has [AlgoliaTask]
      print('\n\n');
      expect(taskDeleteIndex.runtimeType, AlgoliaTask);
      print(taskDeleteIndex.data);
    });
  }
```

## Search Parameters
Here is the list of parameters you can use with the search method (search scope).
We have managed to include most commonly used parameters for search functionality
and there many more to be added in future releases.

We have indicated counts of queryable parameters with their availability status
on official Algolia website and what we have managed to support it in this
version of the release. 

##### search (1/1)
- `.search(String value)`

##### attributes (2/2)
- `.setAttributesToRetrieve(List<String> value)`
- `.setRestrictSearchableAttributes(List<String> value)`

##### filtering (2/6)
- `.setFilters(String value)`
- `.setFacetFilter(String value)` This can be used multiple times in a query.

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

##### typos (0/5)

##### geo-search (0/7)

##### languages (0/3)

##### query-rules (0/2)

##### query-strategy (0/7)

##### advanced (0/11)

##### GET RESULT
- `.getObjects()`


<hr/>
Algolia is a Knoxpo original.
<br/>
<a href="https://knoxpo.com" target="_knoxpo"><img src="https://www.knoxpo.com/assets/logo.png" width="60"></a>
