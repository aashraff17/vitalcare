import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { patient, doctor, nurse, none }

class AuthState {
  final bool isAuthenticated;
  final UserRole role;
  final String email;

  const AuthState({
    this.isAuthenticated = false,
    this.role = UserRole.none,
    this.email = '',
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserRole? role,
    String? email,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      email: email ?? this.email,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<bool> login(String email, String password) async {
    // Mock authentication
    await Future.delayed(const Duration(seconds: 1)); // Simulate network

    if (password != '123456') return false;

    if (email == 'patient@vitalcare.com') {
      state = AuthState(isAuthenticated: true, role: UserRole.patient, email: email);
      return true;
    } else if (email == 'doctor@vitalcare.com') {
      state = AuthState(isAuthenticated: true, role: UserRole.doctor, email: email);
      return true;
    } else if (email == 'nurse@vitalcare.com') {
      state = AuthState(isAuthenticated: true, role: UserRole.nurse, email: email);
      return true;
    }

    return false;
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
