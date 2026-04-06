import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../../models/user.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  static const _sessionKey = 'current_user_id';
  static const _salt = 'clinical_precision_2025';

  User? _currentUser;
  User? get currentUser => _currentUser;

  // ── Startup check ──────────────────────────────────────────────────────────

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_sessionKey);
    if (userId == null) return false;

    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (rows.isEmpty) {
      await prefs.remove(_sessionKey);
      return false;
    }
    _currentUser = User.fromMap(rows.first);
    return true;
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  /// Returns null on success, an error message on failure.
  Future<String?> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return 'Please enter your email and password.';
    }
    final db = await DatabaseHelper.instance.database;
    final hash = _hashPassword(password, email.trim().toLowerCase());
    final rows = await db.query(
      'users',
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email.trim().toLowerCase(), hash],
    );
    if (rows.isEmpty) return 'Invalid email or password.';

    _currentUser = User.fromMap(rows.first);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, _currentUser!.id);
    return null;
  }

  // ── Register ───────────────────────────────────────────────────────────────

  /// Returns null on success, an error message on failure.
  Future<String?> register({
    required String fullName,
    required String email,
    required String clinicalIdentifier,
    required String role,
    required String password,
    required String confirmPassword,
  }) async {
    if (fullName.trim().isEmpty) return 'Full name is required.';
    if (email.trim().isEmpty) return 'Email is required.';
    if (clinicalIdentifier.trim().isEmpty) return 'Clinical identifier is required.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    if (password != confirmPassword) return 'Passwords do not match.';

    final db = await DatabaseHelper.instance.database;

    final emailRows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    if (emailRows.isNotEmpty) return 'An account with this email already exists.';

    final usernameRows = await db.query(
      'users',
      where: 'clinical_identifier = ?',
      whereArgs: [clinicalIdentifier.trim()],
    );
    if (usernameRows.isNotEmpty) return 'This clinical identifier is already taken.';

    final user = User(
      id: const Uuid().v4(),
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: _hashPassword(password, email.trim().toLowerCase()),
      clinicalIdentifier: clinicalIdentifier.trim(),
      role: role,
      createdAt: DateTime.now(),
    );

    await db.insert('users', user.toMap());
    return null;
  }

  // ── Update credentials ─────────────────────────────────────────────────────

  Future<String?> updateCredentials({
    required String clinicalIdentifier,
    String? currentPassword,
    String? newPassword,
  }) async {
    if (_currentUser == null) return 'Not logged in.';
    if (clinicalIdentifier.trim().isEmpty) return 'Clinical identifier cannot be empty.';

    final db = await DatabaseHelper.instance.database;

    // Check identifier uniqueness (excluding current user)
    final rows = await db.query(
      'users',
      where: 'clinical_identifier = ? AND id != ?',
      whereArgs: [clinicalIdentifier.trim(), _currentUser!.id],
    );
    if (rows.isNotEmpty) return 'This clinical identifier is already taken.';

    final updates = <String, dynamic>{
      'clinical_identifier': clinicalIdentifier.trim(),
    };

    if (newPassword != null && newPassword.isNotEmpty) {
      if (currentPassword == null || currentPassword.isEmpty) {
        return 'Enter your current password to set a new one.';
      }
      final currentHash = _hashPassword(currentPassword, _currentUser!.email);
      if (currentHash != _currentUser!.passwordHash) {
        return 'Current password is incorrect.';
      }
      if (newPassword.length < 6) return 'New password must be at least 6 characters.';
      updates['password_hash'] = _hashPassword(newPassword, _currentUser!.email);
    }

    await db.update('users', updates, where: 'id = ?', whereArgs: [_currentUser!.id]);

    // Refresh cached user
    final updated = await db.query('users', where: 'id = ?', whereArgs: [_currentUser!.id]);
    if (updated.isNotEmpty) _currentUser = User.fromMap(updated.first);
    return null;
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _hashPassword(String password, String email) {
    final input = '$email:$password:$_salt';
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
