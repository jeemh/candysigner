import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  User? _current;

  User? get user => _current;
  bool get isLoggedIn => _current != null;

  Future<void> loadFromStorage() async {
    final idStr = await _storage.read(key: 'user_id');
    if (idStr == null) return;
    _current = User(
      id: int.parse(idStr),
      username: await _storage.read(key: 'user_email') ?? '',
      name: await _storage.read(key: 'user_name') ?? '',
      gender: await _storage.read(key: 'user_gender') ?? '',
      phoneOrInsta: await _storage.read(key: 'user_contact'),
      location: await _storage.read(key: 'user_location'),
      mbti: await _storage.read(key: 'user_mbti'),
    );
    notifyListeners();
  }

  Future<void> saveAndLogin(User user) async {
    _current = user;
    await _storage.write(key: 'user_id', value: user.id.toString());
    await _storage.write(key: 'user_email', value: user.username);
    await _storage.write(key: 'user_name', value: user.name);
    await _storage.write(key: 'user_gender', value: user.gender);
    await _storage.write(key: 'user_contact', value: user.phoneOrInsta ?? '');
    await _storage.write(key: 'user_location', value: user.location ?? '');
    await _storage.write(key: 'user_mbti', value: user.mbti ?? '');
    notifyListeners();
  }

  Future<void> logout() async {
    _current = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}
