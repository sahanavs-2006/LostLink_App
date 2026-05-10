import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/item_model.dart';
import '../core/utils/helpers.dart';

/// Service for managing lost and found items using Firestore and Firebase Storage.
class ItemService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<ItemModel> _items = [];
  bool _isLoading = false;

  List<ItemModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  /// Getters for specific item types
  List<ItemModel> get lostItems => _items.where((i) => i.isLostReport).toList();
  List<ItemModel> get foundItems => _items.where((i) => i.isFoundReport).toList();

  /// Fetch all items from Firestore
  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('items').orderBy('reportedAt', descending: true).get();
      _items.clear();
      for (var doc in snapshot.docs) {
        _items.add(ItemModel.fromMap(doc.data()));
      }
    } catch (e) {
      debugPrint('Error fetching items: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Upload image to Firebase Storage and return its download URL
  Future<String?> uploadItemImage(File imageFile) async {
    try {
      final fileName = '${const Uuid().v4()}.jpg';
      final ref = _storage.ref().child('item_images/$fileName');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image to Storage: $e');
      // Hackathon fallback: if user is not authenticated with Firebase, save locally!
      return imageFile.path;
    }
  }

  /// Report a lost item
  Future<ItemModel> reportLostItem({
    required String title,
    required String description,
    required String category,
    required String color,
    String? brand,
    String? contents,
    required String transportType,
    String? routeNumber,
    String? stationName,
    String? locationDetails,
    required String userId,
    List<String> imageUrls = const [],
  }) async {
    final item = ItemModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      category: category,
      color: color,
      brand: brand,
      contents: contents,
      transportType: transportType,
      routeNumber: routeNumber,
      stationName: stationName,
      locationDetails: locationDetails,
      reportedAt: DateTime.now(),
      status: 'lost',
      reporterType: 'owner',
      reportedBy: userId,
      imageUrls: imageUrls,
    );

    await _db.collection('items').doc(item.id).set(item.toMap());
    _items.insert(0, item);
    notifyListeners();
    return item;
  }

  /// Log a found item and run matching engine
  Future<ItemModel> logFoundItem({
    required String title,
    required String description,
    required String category,
    required String color,
    String? brand,
    String? contents,
    required String transportType,
    String? routeNumber,
    required String stationName,
    String? locationDetails,
    required String userId,
    List<String> imageUrls = const [],
  }) async {
    final foundItem = ItemModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      category: category,
      color: color,
      brand: brand,
      contents: contents,
      transportType: transportType,
      routeNumber: routeNumber,
      stationName: stationName,
      locationDetails: locationDetails,
      reportedAt: DateTime.now(),
      status: 'found',
      reporterType: 'finder',
      reportedBy: userId,
      imageUrls: imageUrls,
    );

    await _db.collection('items').doc(foundItem.id).set(foundItem.toMap());
    _items.insert(0, foundItem);
    
    // Run Matching Engine against lost reports
    _runMatchingEngine(foundItem);
    
    notifyListeners();
    return foundItem;
  }

  /// Simple matching engine logic
  void _runMatchingEngine(ItemModel foundItem) {
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.isLostReport && item.status == 'lost') {
        double confidence = Helpers.calculateMatchConfidence(item, foundItem);
        
        if (confidence > 0.6) {
          // Update lost item with match info
          final matchedItem = item.copyWith(
            status: 'matched',
            matchConfidence: confidence,
            claimCode: Helpers.generateClaimCode(),
            matchedItemId: foundItem.id,
          );
          
          _items[i] = matchedItem;
          _db.collection('items').doc(matchedItem.id).update(matchedItem.toMap());
          
          // Also update the found item
          final updatedFoundItem = foundItem.copyWith(
            status: 'matched',
            matchedItemId: item.id,
          );
          _db.collection('items').doc(updatedFoundItem.id).update(updatedFoundItem.toMap());
        }
      }
    }
  }

  List<ItemModel> getByUser(String userId) => 
      _items.where((i) => i.reportedBy == userId).toList();

  List<ItemModel> getByStatus(String status) => 
      _items.where((i) => i.status == status).toList();

  /// Mock loading demo data
  void loadDemoData() {
    fetchItems();
  }
}
