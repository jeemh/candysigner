import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/api_service.dart';
import 'contact_menu_page.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import 'register_page.dart';

final storage = FlutterSecureStorage();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _error;
  final ApiService _api = ApiService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // 사용자가 취소함

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        final result = await _api.loginWithGoogle(idToken);
        if (result is User) {
          if (!mounted) return;
          context.read<AuthProvider>().saveAndLogin(result);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ContactMenuPage()),
            (route) => false,
          );
        } else if (result is Map && result['needsRegister'] == true) {
          // 회원가입 필요 -> 회원가입 페이지로 이동 (정보 프리필)
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => RegisterPage(
                    initialUsername: result['username'],
                    initialName: result['name'],
                  ),
            ),
          );
        } else {
          setState(() => _error = '구글 로그인 서버 인증 실패');
        }
      } else {
        // idToken이 null인 경우 에러 메시지 표시
        setState(() => _error = '구글 인증 토큰을 가져오지 못했습니다. (설정 확인 필요)');
      }
    } catch (error) {
      setState(() => _error = '구글 로그인 실패: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _handleGoogleSignIn,
              icon: const Icon(Icons.login),
              label: const Text('Google로 로그인'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
