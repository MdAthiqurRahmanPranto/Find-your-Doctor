import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;
  UserModel? _currentUserModel;
  UserModel? get currentUserModel => _currentUserModel;

  StreamSubscription<DocumentSnapshot>? _userDocSubscription;
  String? _banNotificationMessage;
  String? get banNotificationMessage => _banNotificationMessage;

  AuthService() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _currentUserModel = null;
        _userDocSubscription?.cancel();
        _userDocSubscription = null;
        notifyListeners();
      } else {
        _listenToUserDocument(user.uid);
      }
    });
  }

  void _listenToUserDocument(String uid) {
    _userDocSubscription?.cancel();
    _userDocSubscription = _firestore.collection('users').doc(uid).snapshots().listen(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final userModel = UserModel.fromMap(snapshot.data()!, snapshot.id);
          
          // Check if banned
          if (userModel.isBanned) {
            _handleBannedUser();
          } else {
            _currentUserModel = userModel;
            notifyListeners();
          }
        }
      },
      onError: (err) {
        debugPrint("Error listening to user document: $err");
      },
    );
  }

  void clearBanBanner() {
    _banNotificationMessage = null;
    notifyListeners();
  }

  Future<void> _handleBannedUser() async {
    _banNotificationMessage = 'Your account has been restricted by an administrator.';
    _currentUserModel = null;
    await _auth.signOut();
    notifyListeners();
  }

  // Sign Up
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;
      final newUser = UserModel(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
        isBanned: false,
        createdAt: DateTime.now(),
      );

      // Store in Firestore
      await _firestore.collection('users').doc(uid).set(newUser.toMap());
      _currentUserModel = newUser;
      notifyListeners();

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e.code);
    } catch (e) {
      throw 'Failed to create account: $e';
    }
  }

  // Sign In
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        // Fallback user document creation if missing
        final fallbackUser = UserModel(
          uid: uid,
          name: email.split('@').first,
          email: email,
          role: 'user',
          isBanned: false,
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(uid).set(fallbackUser.toMap());
        _currentUserModel = fallbackUser;
        notifyListeners();
        return fallbackUser;
      }

      final userModel = UserModel.fromMap(doc.data()!, doc.id);

      if (userModel.isBanned) {
        await _auth.signOut();
        _banNotificationMessage = 'Your account has been restricted by an administrator.';
        notifyListeners();
        throw 'Your account has been restricted by an administrator.';
      }

      _currentUserModel = userModel;
      notifyListeners();
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e.code);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUserModel = null;
    _userDocSubscription?.cancel();
    notifyListeners();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No registered account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters long.';
      default:
        return 'Authentication failed: $code';
    }
  }

  @override
  void dispose() {
    _userDocSubscription?.cancel();
    super.dispose();
  }
}
