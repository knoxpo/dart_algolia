@Timeout(const Duration(seconds: 60))
import 'package:test/test.dart';
import 'package:algolia/algolia.dart';

void main() async {
  ///
  /// Initiate Algolia in your project
  ///
  Algolia algolia = Application.algolia;
  AlgoliaTask taskAdded,
      taskUpdated,
      taskDeleted,
      taskBatch,
      taskReplace,
      taskClearIndex,
      taskDeleteIndex;
  AlgoliaObjectSnapshot addedObject;

  /// Storage for returned Object IDs
  final List<String> ids = [];

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
      'price': 200,
    };
    taskAdded = await algolia.instance.index('contacts').addObject(addData);
    await taskAdded.waitTask();

    // Checking if has [AlgoliaTask]
    expect(taskAdded.runtimeType, AlgoliaTask);
    print(taskAdded.data);
    print('\n\n');
  });

  ///
  /// 2. Perform Get Object to existing Index.
  ///
  test("2. Perform Get Object to existing Index.", () async {
    addedObject = await algolia.instance
        .index('contacts')
        .object(taskAdded.data['objectID'].toString())
        .getObject();

    // Checking if has [AlgoliaObjectSnapshot]
    expect(addedObject.runtimeType, AlgoliaObjectSnapshot);
    print(addedObject.data);
    print('\n\n');
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
    expect(taskUpdated.runtimeType, AlgoliaTask);
    print(taskUpdated.data);
    print('\n\n');
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
    expect(taskDeleted.runtimeType, AlgoliaTask);
    print(taskDeleted.data);
    print('\n\n');
  });

  ///
  /// 5. Perform Batch
  ///
  test("5. Perform Batch", () async {
    AlgoliaBatch batch = algolia.instance.index('contacts').batch();
    batch.clearIndex();
    // batchB.clearIndex();
    for (int i = 0; i < 10; i++) {
      Map<String, dynamic> addData = {
        'name': 'John ${DateTime.now().microsecond}',
        'contact': '+1 ${DateTime.now().microsecondsSinceEpoch}',
        'email': 'johan.${DateTime.now().microsecond}@example.com',
        'isDelete': false,
        'status': 'published',
        'createdAt': DateTime.now(),
        'modifiedAt': DateTime.now(),
        'price': i+200,
      };
     
      batch.addObject(addData);
    }

    // Get Result/Objects
    taskBatch = await batch.commit();
    await taskBatch.waitTask();

    // Checking if has [AlgoliaTask]
    expect(taskBatch.runtimeType, AlgoliaTask);
    print(taskBatch.data);
    print('\n\n');

    // Add ids to list for test 8
    final List batchIds = taskBatch.data['objectIDs'];
    ids.addAll([batchIds[3], batchIds[4]]);
  });

  

  ///
  /// 7. Perform Query
  ///
  test("7. Perform Multiple Queries", () async {
    AlgoliaQuery queryA = algolia.instance.index('contacts').search('john');
    AlgoliaQuery queryB = algolia.instance.index('contacts_alt').search('jo');

    // Perform multiple facetFilters
    queryA = queryA.setFacetFilter('status:published');
    queryA = queryA.setFacetFilter('isDelete:false');

    // Get Result/Objects
    List<AlgoliaQuerySnapshot> snap =
        await algolia.multipleQueries.addQueries([queryA, queryB]).getObjects();
    // Checking if has [List<AlgoliaQuerySnapshot>]
    expect(snap.length, 2);
    print('Queries count: ${snap.length}');
    print('\n\n');
  });

  ///
  /// 8. Get Objects by ObjectID
  ///
  test('8. Get Objects by ObjectID', () async {
    List<AlgoliaObjectSnapshot> results =
        await algolia.instance.index('contacts').getObjectsByIds(ids);

    expect(results.length, 2);
    expect(results.first.objectID, ids.first);
  });

  ///
  /// 9. Perform List all Indices
  ///
  test("9. Perform List all Indices", () async {
    AlgoliaIndexesSnapshot indices = await algolia.instance.getIndices();

    // Checking if has [AlgoliaIndexesSnapshot]
    expect(indices.runtimeType, AlgoliaIndexesSnapshot);
    print('Indices count: ${indices.items.length}');
    print('\n\n');
  });

  ///
  /// 10. Get Settings of 'contacts' index
  ///
  test("10. Get Settings of 'contacts' index", () async {
    Map<String, dynamic> settings =
        await algolia.instance.index('contacts').settings.getSettings();

    // Checking if has [Map<String, dynamic>]
    expect(settings.isEmpty, false);
    print(settings);
    print('\n\n');
  });


  ///
  /// 12. Replace all objects in index.
  ///

  test("12. Replace all objects in index.", () async {
    taskReplace = await algolia.instance.index('contacts').replaceAllObjects(
      [
        {'newObject': true}
      ],
    );

    // Checking if has [AlgoliaTask]
    expect(taskReplace.runtimeType, AlgoliaTask);
    print(taskReplace.data);
    print('\n\n');
  });

  ///
  /// 13. Perform Clear Index.
  ///
  test("13. Perform Clear Index.", () async {
    taskClearIndex = await algolia.instance.index('contacts').clearIndex();

    // Checking if has [AlgoliaTask]
    expect(taskClearIndex.runtimeType, AlgoliaTask);
    print(taskClearIndex.data);
    print('\n\n');
  });

  ///
  /// 14. Perform Delete Index.
  ///
  test("14. Perform Delete Indexes.", () async {
    AlgoliaSettings settings = algolia.instance.index('contacts').settings;
    settings = settings.setReplicas([]);
    final AlgoliaTask removeReplicas = await settings.setSettings();
    await removeReplicas.waitTask();
    taskDeleteIndex = await algolia.instance.index('contacts').deleteIndex();
    taskDeleteIndex =
        await algolia.instance.index('contacts_copy_1').deleteIndex();
    taskDeleteIndex =
        await algolia.instance.index('contacts_copy_2').deleteIndex();

    // Checking if has [AlgoliaTask]
    expect(taskDeleteIndex.runtimeType, AlgoliaTask);
    print(taskDeleteIndex.data);
    print('\n\n');
  });

  /**
	 * Search TEST
	 */
  test("1. Perform Query", () async {
    AlgoliaQuery query = algolia.instance.index('contacts').search('john');

    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();

    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("2. Perform SimilarQuery", () async {
    AlgoliaQuery query =
        algolia.instance.index('contacts').setSimilarQuery('775');

    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();

    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  /**
	 *  Attributes TEST
	 */
  test("1. Perform SearchableAttributes", () async {
    var settings = algolia.instance
        .index('contacts')
        .settings
        .setSearchableAttributes(['name']);

    AlgoliaTask response = await settings.setSettings();

    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });

  test("2. Perform AttributesForFaceting", () async {
    var settings = algolia.instance
        .index('contacts')
        .settings
        .setAttributesForFaceting(['name', 'searchable(email)']);

    AlgoliaTask response = await settings.setSettings();

    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });

  test("3. Perform UnretrievableAttributes", () async {
    var settings = algolia.instance
        .index('contacts')
        .settings
        .setUnRetrievableAttributes(['isDelete']);

    AlgoliaTask response = await settings.setSettings();

    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });

  test("4. Perform AttributesToRetrieve", () async {
    var settings = algolia.instance
        .index('contacts')
        .settings
        .setAttributesToRetrieve(['email']);

    AlgoliaTask response = await settings.setSettings();

    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });

  test("5. Perform RestrictSearchableAttributes", () async {
    AlgoliaQuery query = algolia.instance
        .index('contacts')
        .setRestrictSearchableAttributes(['name']);

    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();

    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  /**
	 * Ranking TEST
	 */
  test("1. Perform Ranking", () async {
    var settings =
        algolia.instance.index('contacts').settings.setRanking(['words']);

    AlgoliaTask response = await settings.setSettings();

    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });

  test("2. Perform custom ranking", () async {
    var settings = algolia.instance
        .index('contacts')
        .settings
        .setCustomRanking(['asc(createdAt)']);

    AlgoliaTask response = await settings.setSettings();

    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });

  /*test("11. Set Settings of 'contacts' index", () async {
    AlgoliaSettings settings =
    await algolia.instance.index('contacts').settings;
  
    settings =
        settings.setReplicas(const ['contacts_copy_1', 'contacts_copy_2']);
  
    AlgoliaTask response = await settings.setSettings();
  
    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });*/

  
  /**
	 * Filter TEST
	 */
  test("1. Perform Filter", () async {
    AlgoliaQuery query = algolia.instance.index('contacts').search('john');

    // Perform multiple Filter
    query = query.setFilters('status:published');

    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();

    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("2. Perform Face Filter", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');

    // Perform multiple facetFilters
    query = query.setFacetFilter('email:johan.794@example.com');

    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();

    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("3. Perform Optional Filter", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');

    query = query.setOptionalFilter('isDelete:false');

    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();

    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("4. Perform Numeric Filter", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');

    query = query.setNumericFilter('price > 200');

    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();

    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("5. Tag Filter", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setTagFilter('name');
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("6. Sum Or Filter Scores Filter", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setSumOrFiltersScore(true);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });
  
  
  /**
   * Facets TEST
   */
  test("1. Perform Facets", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setFacets(['name','email']);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("2. Perform Max value per facets", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setMaxValuesPerFacet(50);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("3. Perform faceting After Distinct", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setFacetingAfterDistinct(enable: true);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("4. Perform sortFacetValuesBy", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setSortFacetValuesBy(AlgoliaSortFacetValuesBy.count);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });


  /**
     * Highlighting / Snippeting TEST
   */
  test("1. Perform attributes To Highlight", () async {
    var settings = algolia.instance
        .index('contacts')
        .settings
        .setAttributesToHighlight(['email']);
  
    AlgoliaTask response = await settings.setSettings();
  
    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });

  test("2. Perform attributes To Snippet", () async {
    var settings = algolia.instance
        .index('contacts')
        .settings
        .setAttributesToSnippet(['contact']);
  
    AlgoliaTask response = await settings.setSettings();
  
    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });
  
  test("3. Perform highlight Pre Tag & highlight Post Tag", () async {
    var settings = algolia.instance
        .index('contacts')
        .settings
        .setHighlightPreTag('<em>')
        .setHighlightPostTag('</em>');
  
    AlgoliaTask response = await settings.setSettings();
  
    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });

  test("4. Perform restrict Highlight And Snippet Arrays", () async {
    var settings = algolia.instance
        .index('contacts')
        .settings
        .setRestrictHighlightAndSnippetArrays(enable: true);
  
    AlgoliaTask response = await settings.setSettings();
  
    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });


  /**
   * Pagination TEST
   */
  test("1. Perform page", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setPage(0);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("2. Perform hit per page", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setHitsPerPage(5);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("3. Perform offset", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setOffset(4);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("4. Perform length", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setLength(4);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });
  
  test("5. Perform pagination limited to", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setPaginationLimitedTo(1000);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  /**
   * Typos TEST
   */
  test("1. Perform min word size for 1 typo", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setMinWordSizeFor1Typo(2);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("2. Perform min word size for 2 typo", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setMinWordSizeFor2Typos(4);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });
  
  test("3. Perform typo Tolerance", () async {
    
    //Set default typo tolerance mode
    var settings = algolia.instance.index('contacts').settings.setTypoTolerance(true);
  
    await settings.setSettings();
    
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setTypoTolerance(false);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("4. Perform allow typos on numericTokens", () async {
  
    //Set default typo tolerance mode
    var settings = algolia.instance.index('contacts').settings.setAllowTyposOnNumericTokens(false);
  
    await settings.setSettings();
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setAllowTyposOnNumericTokens(false);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("5. Perform disable typo Tolerance on Attributes", () async {
  
    //Set default typo tolerance mode
    var settings = algolia.instance.index('contacts').settings.setDisableTypoToleranceOnAttributes(['status']);
  
    await settings.setSettings();
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setDisableTypoToleranceOnAttributes(['status']);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("6. Perform separators to index", () async {
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setSeparatorsToIndex('+#');
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });


  /**
   * Geo Search TEST
   */
  test("1. Perform around LatLng", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setAroundLatLng('40.71, -74.01');
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("2. Perform around LatLng ViaIP", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setAroundLatLngViaIP(true);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("3. Perform around Radius", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setAroundRadius('all');
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("4. Perform around PrecisetCamelCaseAttributession", () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setAroundPrecision(100);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("5. Perform inside polygon",   () async {
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setInsidePolygon([
      BoundingPolygonBox(
        p1Lat:  46.650828100116044,
        p1Lng: 7.123046875,
        p2Lat: 45.17210966999772,
        p2Lng: 1.009765625,
        p3Lat: 49.62625916704081,
        p3Lng: 4.6181640625
      )
    ]);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });
  
  
  /**
   * Language TEST
   */
  test("1. Perform ignore Plurals", () async {
  
    var settings = algolia.instance.index('contacts').settings.setQueryLanguages(['es']).setIgnorePlurals(true);
  
    await settings.setSettings();
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setIgnorePlurals(true);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("2. Perform remove stopWords", () async {
  
    var settings = algolia.instance.index('contacts').settings.setQueryLanguages(['es']).setRemoveStopWords(true);
  
    await settings.setSettings();
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setRemoveStopWords(['ca','es']);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });
  
  test("3. Perform camel case attributes", () async {
  
    var settings = algolia.instance.index('contacts').settings.setCamelCaseAttributes(['name']);
  
    var response = await settings.setSettings();

    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });

  test("4. Perform decompounded attributes", () async {
  
    var settings = algolia.instance.index('contacts').settings.setDecompoundedAttributes(['name']);
  
    var response = await settings.setSettings();
  
    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });

  test("5. Perform keep diacritics on characters", () async {
  
    var settings = algolia.instance.index('contacts').settings.setkeepDiacriticsOnCharacters('øé');
  
    var response = await settings.setSettings();
  
    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });
  
  test("6. Perform query languages", () async {
  
    var settings = algolia.instance.index('contacts').settings.setQueryLanguages(['es','ja']);
  
    var response = await settings.setSettings();
  
    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });

  test("7. Perform index languages", () async {
  
    var settings = algolia.instance.index('contacts').settings.setIndexLanguages(['es','ja']);
  
    var response = await settings.setSettings();
  
    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });

  test("8. Perform natural languages", () async {
  
    var settings = algolia.instance.index('contacts').settings.setNaturalLanguages(['fr']);
  
    var response = await settings.setSettings();
  
    // Checking if has [AlgoliaTask]
    expect(response.runtimeType, AlgoliaTask);
    print(response);
    print('\n\n');
  });
  
  
  /**
   * Rules TEST
   */
  test("1. Perform enable rules", () async {
  
    var settings = algolia.instance.index('contacts').settings.setEnableRules(enabled: true);
  
    await settings.setSettings();
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setEnableRules(enabled: false);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("2. Perform rule contexts", () async {
    
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setRuleContexts(['email']);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });


  /**
   * Personalization TEST
   */
  test("1. Perform enable personalization", () async {
  
    //Enable personalization for every search
    var settings = algolia.instance.index('contacts').settings.setEnablePersonalization(enabled: true);
  
    await settings.setSettings();
  
    //Enable personalization for the current search
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setEnablePersonalization(enabled: false);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("2. Perform personalization impact", () async {
    
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setPersonalizationImpact(value: 20);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("2. Perform userToken", () async {
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setUserToken(value: '123456');
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });
  
  
  /**
   * Query Strategy
   */
  test("1. Perform queryType", () async {
  
    //Set default query type
    var settings = algolia.instance.index('contacts').settings.setQueryType(QueryType.prefixLast);
  
    await settings.setSettings();

    //Override default query type for the current search
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setQueryType(QueryType.prefixAll);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("2. Perform remove words if no results", () async {
  
    //Set default strategy to remove words from the query
    var settings = algolia.instance.index('contacts').settings.setRemoveWordsIfNoResults(RemoveWordsIfNoResults.none);
  
    await settings.setSettings();
  
    //Override default strategy to remove words from the query for the current search
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setRemoveWordsIfNoResults(RemoveWordsIfNoResults.firstWords);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("3. Perform disable Prefix On Attributes", () async {
    
    var settings = algolia.instance.index('contacts').settings.setDisablePrefixOnAttributes(['sku']);

    AlgoliaTask result = await settings.setSettings();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(result.runtimeType, AlgoliaTask);
    print(result);
    print('\n\n');
  });

  test("4. Perform disable exact on attributes", () async {
  
    var settings = algolia.instance.index('contacts').settings.setDisableExactOnAttributes(['email']);
  
    AlgoliaTask result = await settings.setSettings();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(result.runtimeType, AlgoliaTask);
    print(result);
    print('\n\n');
  });

  test("6. Perform exact on singleWordQuery", () async {
  
    //Set default exact ranking criterion computation on single word query
    var settings = algolia.instance.index('contacts').settings.setExactOnSingleWordQuery(ExactOnSingleWordQuery.attribute);
  
    await settings.setSettings();
  
    //Override default exact ranking criterion computation on single word query for the current search
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setExactOnSingleWordQuery(ExactOnSingleWordQuery.none);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });
  
  
  /**
   * Performance TEST
   */
  test("1. Perform numericAttributesForFiltering", () async {
    
    var settings = algolia.instance.index('contacts').settings.setNumericAttributesForFiltering(value: ['quantity']);
  
    AlgoliaTask result = await settings.setSettings();
    
    expect(result.runtimeType, AlgoliaTask);
    print(result);
    print('\n\n');
  });

  test("2. Perform allowCompressionOfIntegerArray", () async {
    
    var settings = algolia.instance.index('contacts').settings.setAllowCompressionOfIntegerArray(enabled: true);
  
    AlgoliaTask result = await settings.setSettings();
    
    expect(result.runtimeType, AlgoliaTask);
    print(result);
    print('\n\n');
  });
  
  
  /**
   * Advance TEST
   */
  test("1. Perform attributeForDistinct", () async {
  
    var settings = algolia.instance.index('contacts').settings.setAttributeForDistinct('url');
  
    AlgoliaTask result = await settings.setSettings();
  
    expect(result.runtimeType, AlgoliaTask);
    print(result);
    print('\n\n');
  });

  test("2. Perform distinct", () async {
  
    var settings = algolia.instance.index('contacts').settings.setDistinct(value: 0);
  
    AlgoliaTask result = await settings.setSettings();
  
    expect(result.runtimeType, AlgoliaTask);
    print(result);
    print('\n\n');
  });

  test("3. Perform getRankingInfo", () async {
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setGetRankingInfo(enabled: true);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("4. Perform clickAnalytics", () async {
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setClickAnalytics(enabled: true);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("5. Perform analytics", () async {
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setAnalytics(enabled: false);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("6. Perform analyticsTags", () async {
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setAnalyticsTags(['front_end']);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("7. Perform synonyms", () async {
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setSynonyms(enabled: false);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("8. Perform replaceSynonymsInHighlight", () async {
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setReplaceSynonymsInHighlight(enabled: false);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("9. Perform maxFacetHits", () async {
  
    //Set default number of facet values to return during a search for facet values.
    var settings = algolia.instance.index('contacts').settings.setMaxFacetHits(10);
  
    await settings.setSettings();
  
    //Override default number of facet values to return during a search for facet values for the current search
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setMaxFacetHits(5);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("10. Perform attributeCriteriaComputedByMinProximity", () async {
    
    var settings = algolia.instance.index('contacts').settings.setAttributeCriteriaComputedByMinProximity(enabled: true);
  
    AlgoliaTask result =await settings.setSettings();
    
    // Checking if has [AlgoliaQuerySnapshot]
    expect(result.runtimeType, AlgoliaTask);
    print(result);
    print('\n\n');
  });

  test("11. Perform enableABTest", () async {
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setEnableABTest(enabled: true);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });

  test("12. Perform percentileComputation", () async {
  
    AlgoliaQuery query = algolia.instance.index('contacts');
  
    query = query.setPercentileComputation(enabled: false);
  
    // Get Result/Objects
    AlgoliaQuerySnapshot snap = await query.getObjects();
  
    // Checking if has [AlgoliaQuerySnapshot]
    expect(snap.runtimeType, AlgoliaQuerySnapshot);
    print('Hits count: ${snap.nbHits}');
    print('\n\n');
  });
  
}

class Application {
  static final Algolia algolia = Algolia.init(
    applicationId: 'YOUR_APPLICATION_ID',
    apiKey: 'YOUR_API_KEY',
  );
}
