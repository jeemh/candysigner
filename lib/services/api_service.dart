import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/contact.dart';

class ApiService {
  static final String _baseUrl =
      Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';

  /// ID/비밀번호 로그인
  Future<User?> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  /// 회원가입
  Future<bool> register({
    required String username,
    required String password,
    required String name,
    required String gender,
    String? phoneOrInsta,
    String? location,
    String? mbti,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'name': name,
        'gender': gender,
        'phone_or_insta': phoneOrInsta,
        'location': location,
        'mbti': mbti,
      }),
    );
    return res.statusCode == 201;
  }

  // 구글 로그인은 사용하지 않음. 필요하다면 다시 주석 해제
  // Future<User?> loginWithGoogle(String idToken) async {
  //   final res = await http.post(
  //     Uri.parse('$_baseUrl/auth/google'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode({'idToken': idToken}),
  //   );
  //   if (res.statusCode == 200) {
  //     return User.fromJson(jsonDecode(res.body));
  //   }
  //   return null;
  // }

  Future<bool> createContact({
    required int userId,
    required String intro,
    required String contactValue,
    required String gender,
    String? location,
    String? mbti,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/contacts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'intro': intro,
        'contact_value': contactValue,
        'location': location,
        'gender': gender,
        'mbti': mbti,
      }),
    );
    return res.statusCode == 201;
  }

  Future<List<Contact>> fetchNearbyContacts(
    String location, {
    String? excludeGender,
  }) async {
    final res = await http.get(
      Uri.parse(
        '$_baseUrl/contacts?location=$location${excludeGender != null ? '&excludeGender=$excludeGender' : ''}',
      ),
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Contact.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> deleteContact(int id) async {
    final res = await http.delete(Uri.parse('$_baseUrl/contacts/$id'));
    return res.statusCode == 200;
  }

  /// 가장 오래된 연락처 하나를 가져오고 서버에서 삭제 (동일 성별 제외)
  Future<Contact?> drawContact(String location, String userGender) async {
    final list = await fetchNearbyContacts(location, excludeGender: userGender);
    if (list.isEmpty) return null;
    final first = list.first;
    await deleteContact(first.id);
    return first;
  }
}
