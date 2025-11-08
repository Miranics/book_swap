import '../../domain/models/user_model.dart';

/// Mock Authentication Repository for web demo (no Firebase dependency)
class MockAuthRepository {
  static final MockAuthRepository _instance = MockAuthRepository._internal();
  
  factory MockAuthRepository() {
    return _instance;
  }

  MockAuthRepository._internal();

  // In-memory storage
  final Map<String, UserModel> _users = {
    'demo@example.com': UserModel(
      id: 'demo_user_1',
      email: 'demo@example.com',
      displayName: 'Demo User',
      profileImageUrl: 'https://via.placeholder.com/150',
      emailVerified: true,
      createdAt: DateTime.now(),
    ),
    'user2@example.com': UserModel(
      id: 'demo_user_2',
      email: 'user2@example.com',
      displayName: 'John Doe',
      profileImageUrl: 'https://via.placeholder.com/150',
      emailVerified: true,
      createdAt: DateTime.now(),
    ),
  };

  UserModel? _currentUser;

  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (_users.containsKey(email)) {
      throw Exception('Email already in use');
    }

    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      profileImageUrl: 'https://via.placeholder.com/150',
      emailVerified: true, // Auto-verify in mock
      createdAt: DateTime.now(),
    );

    _users[email] = newUser;
    _currentUser = newUser;
    return newUser;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final user = _users[email];
    if (user == null) {
      throw Exception('User not found');
    }

    if (password.length < 6) {
      throw Exception('Invalid password');
    }

    _currentUser = user;
    return user;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  bool get isAuthenticated => _currentUser != null;

  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? profileImageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
      );
    }
  }

  Future<void> resendEmailVerification() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock: email verification is instant
  }
}
