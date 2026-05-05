import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

/// Authentication service using Firebase Auth and Firestore.
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  AuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Called whenever Firebase Auth state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      // Fetch additional user data from Firestore
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!);
      } else {
        // Handle case where auth exists but firestore doc doesn't (shouldn't happen with proper registration)
        _currentUser = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          phone: '',
          role: AppConstants.roleCommuter,
          createdAt: DateTime.now(),
        );
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // _onAuthStateChanged will handle the rest
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset Password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Reset password error: $e');
      return false;
    }
  }

  /// Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'commuter',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Create auth user
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = result.user!;
      
      // 2. Update display name
      await firebaseUser.updateDisplayName(name);

      // 3. Create Firestore document
      final user = UserModel(
        id: firebaseUser.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(firebaseUser.uid).set(user.toMap());
      
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> loginAsRole(String role) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Bypass Firebase and create a mock user session for the demo
    _currentUser = UserModel(
      id: 'demo_${role}_user',
      name: 'Demo ${role[0].toUpperCase()}${role.substring(1)}',
      email: '$role@demo.com',
      phone: '+1234567890',
      role: role,
      createdAt: DateTime.now(),
    );
    
    _isLoading = false;
    notifyListeners();
  }

  /// Update user profile
  Future<void> updateProfile({
    required String name,
    required String phone,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.copyWith(
      name: name,
      phone: phone,
      profileImageUrl: profileImageUrl,
    );
    
    // In a real app, we would update this in Firestore
    if (!_currentUser!.id.startsWith('demo_')) {
      await _db.collection('users').doc(_currentUser!.id).update({
        'name': name,
        'phone': phone,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      });
    }
    
    notifyListeners();
  }
}
