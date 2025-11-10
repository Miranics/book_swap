import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;

      // Send email verification
      await user.sendEmailVerification();

      // Create user profile in Firestore
      final userModel = UserModel(
        id: user.uid,
        email: email,
        displayName: displayName,
        emailVerified: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(
            userModel.toMap(),
          );

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;

      // Check if email is verified
      await user.reload();
      if (!user.emailVerified) {
        await logout();
        throw Exception('Email not verified. Please check your email.');
      }

      // Get user profile from Firestore
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        if ((data['emailVerified'] as bool? ?? false) != user.emailVerified) {
          await userDocRef.update({'emailVerified': user.emailVerified});
          data['emailVerified'] = user.emailVerified;
        }
        return UserModel.fromMap(data, user.uid);
      } else {
        // Create profile if it doesn't exist
        final userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          emailVerified: user.emailVerified,
          createdAt: DateTime.now(),
        );

        await userDocRef.set(userModel.toMap());

        return userModel;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Stream<User?> getAuthStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        final userDocRef = _firestore.collection('users').doc(user.uid);
        final userDoc = await userDocRef.get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          if ((data['emailVerified'] as bool? ?? false) != user.emailVerified) {
            await userDocRef.update({'emailVerified': user.emailVerified});
            data['emailVerified'] = user.emailVerified;
          }
          return UserModel.fromMap(data, user.uid);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String displayName,
    String? profileImageUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': displayName,
          if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        });
      }
    } catch (e) {
      rethrow;
    }
  }
}
