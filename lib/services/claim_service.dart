import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/claim_model.dart';
import '../core/utils/helpers.dart';

/// Service for managing claims and verification using Firestore.
class ClaimService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<ClaimModel> _claims = [];
  bool _isLoading = false;

  List<ClaimModel> get claims => List.unmodifiable(_claims);
  bool get isLoading => _isLoading;

  List<ClaimModel> get pendingClaims =>
      _claims.where((c) => c.status == 'pending').toList();

  /// Fetch all claims
  Future<void> fetchClaims() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('claims').orderBy('createdAt', descending: true).get();
      _claims.clear();
      for (var doc in snapshot.docs) {
        _claims.add(ClaimModel.fromMap(doc.data()));
      }
    } catch (e) {
      debugPrint('Error fetching claims: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Submit a claim
  Future<ClaimModel> submitClaim({
    required String lostItemId,
    required String foundItemId,
    required String claimantId,
    required Map<String, String> verificationAnswers,
  }) async {
    _isLoading = true;
    notifyListeners();

    final claim = ClaimModel(
      id: const Uuid().v4(),
      lostItemId: lostItemId,
      foundItemId: foundItemId,
      claimantId: claimantId,
      claimCode: Helpers.generateClaimCode(),
      status: 'pending',
      verificationAnswers: verificationAnswers,
      createdAt: DateTime.now(),
    );

    await _db.collection('claims').doc(claim.id).set(claim.toMap());
    
    // Also update the item status to 'claiming' to prevent double claims
    await _db.collection('items').doc(lostItemId).update({'status': 'claiming'});
    await _db.collection('items').doc(foundItemId).update({'status': 'claiming'});

    _claims.insert(0, claim);
    _isLoading = false;
    notifyListeners();
    return claim;
  }

  /// Verify a claim (by officer)
  Future<void> verifyClaim(String claimId, String officerId) async {
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index == -1) return;

    final updatedClaim = _claims[index].copyWith(
      status: 'verified',
      verifiedBy: officerId,
      verifiedAt: DateTime.now(),
    );

    await _db.collection('claims').doc(claimId).set(updatedClaim.toMap());
    
    // Update the items as 'recovered'
    await _db.collection('items').doc(updatedClaim.lostItemId).update({'status': 'recovered'});
    await _db.collection('items').doc(updatedClaim.foundItemId).update({'status': 'recovered'});

    _claims[index] = updatedClaim;
    notifyListeners();
  }

  /// Reject a claim
  Future<void> rejectClaim(
      String claimId, String officerId, String reason) async {
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index == -1) return;

    final updatedClaim = _claims[index].copyWith(
      status: 'rejected',
      verifiedBy: officerId,
      rejectionReason: reason,
      verifiedAt: DateTime.now(),
    );

    await _db.collection('claims').doc(claimId).set(updatedClaim.toMap());
    
    // Revert item status to 'matched' (or 'lost/found') so it can be claimed again
    await _db.collection('items').doc(updatedClaim.lostItemId).update({'status': 'matched'});
    await _db.collection('items').doc(updatedClaim.foundItemId).update({'status': 'matched'});

    _claims[index] = updatedClaim;
    notifyListeners();
  }

  List<ClaimModel> getByUser(String userId) =>
      _claims.where((c) => c.claimantId == userId).toList();

  ClaimModel? getByCode(String code) {
    try {
      return _claims.firstWhere(
          (c) => c.claimCode.toUpperCase() == code.toUpperCase());
    } catch (_) {
      return null;
    }
  }
}
