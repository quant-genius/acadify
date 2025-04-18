
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for handling Firestore database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Returns a reference to the Firestore instance
  FirebaseFirestore get firestore => _firestore;
  
  /// Creates a document in a collection
  ///
  /// [collection] - The collection to add the document to
  /// [data] - The data to store in the document
  /// [documentId] - Optional ID for the document (auto-generated if not provided)
  Future<DocumentReference> createDocument(
    String collection,
    Map<String, dynamic> data, {
    String? documentId,
  }) async {
    try {
      final collectionRef = _firestore.collection(collection);
      
      if (documentId != null) {
        await collectionRef.doc(documentId).set(data);
        return collectionRef.doc(documentId);
      } else {
        return await collectionRef.add(data);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets a document by ID
  ///
  /// [collection] - The collection containing the document
  /// [documentId] - The ID of the document to retrieve
  Future<DocumentSnapshot> getDocument(String collection, String documentId) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Updates a document
  ///
  /// [collection] - The collection containing the document
  /// [documentId] - The ID of the document to update
  /// [data] - The data to update
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Deletes a document
  ///
  /// [collection] - The collection containing the document
  /// [documentId] - The ID of the document to delete
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets a collection as a stream of snapshots
  ///
  /// [collection] - The collection to stream
  /// [queryBuilder] - Optional function to build a custom query
  Stream<QuerySnapshot> streamCollection(
    String collection, {
    Query Function(Query query)? queryBuilder,
  }) {
    try {
      Query query = _firestore.collection(collection);
      
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      
      return query.snapshots();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets a document as a stream of snapshots
  ///
  /// [collection] - The collection containing the document
  /// [documentId] - The ID of the document to stream
  Stream<DocumentSnapshot> streamDocument(String collection, String documentId) {
    try {
      return _firestore.collection(collection).doc(documentId).snapshots();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets all documents in a collection
  ///
  /// [collection] - The collection to retrieve
  /// [queryBuilder] - Optional function to build a custom query
  Future<QuerySnapshot> getCollection(
    String collection, {
    Query Function(Query query)? queryBuilder,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      
      return await query.get();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Performs a batch write operation
  ///
  /// [operations] - Function that performs operations on the batch
  Future<void> batchWrite(Future<void> Function(WriteBatch batch) operations) async {
    try {
      final batch = _firestore.batch();
      await operations(batch);
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Performs a transaction
  ///
  /// [transaction] - Function that performs operations within the transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionFunction,
  ) async {
    try {
      return await _firestore.runTransaction(transactionFunction);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets documents with pagination
  ///
  /// [collection] - The collection to query
  /// [limit] - The maximum number of documents to retrieve
  /// [orderBy] - The field to order by
  /// [descending] - Whether to order in descending order
  /// [startAfter] - The document to start after (for pagination)
  /// [queryBuilder] - Optional function to build a custom query
  Future<QuerySnapshot> getDocumentsPaginated(
    String collection, {
    required int limit,
    String? orderBy,
    bool descending = false,
    DocumentSnapshot? startAfter,
    Query Function(Query query)? queryBuilder,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      query = query.limit(limit);
      
      return await query.get();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Checks if a document exists
  ///
  /// [collection] - The collection to check
  /// [documentId] - The ID of the document to check
  Future<bool> documentExists(String collection, String documentId) async {
    try {
      final docSnapshot = await _firestore.collection(collection).doc(documentId).get();
      return docSnapshot.exists;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets the count of documents in a collection or query
  ///
  /// [collection] - The collection to count
  /// [queryBuilder] - Optional function to build a custom query
  Future<AggregateQuerySnapshot> getCount(
    String collection, {
    Query Function(Query query)? queryBuilder,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      
      return await query.count().get();
    } catch (e) {
      rethrow;
    }
  }
}
