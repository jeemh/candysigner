import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _mbtiController = TextEditingController();
  String _gender = 'M';
  String? _error;
  bool _isLoading = false;
  final ApiService _api = ApiService();

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final name = _nameController.text.trim();

    if ([username, password, confirm, name].any((e) => e.isEmpty)) {
      setState(() => _error = '필수 항목을 모두 입력하세요');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = '비밀번호는 6자 이상이어야 합니다');
      return;
    }
    if (password != confirm) {
      setState(() => _error = '비밀번호가 일치하지 않습니다');
      return;
    }
    setState(() => _isLoading = true);
    final success = await _api.register(
      username: username,
      password: password,
      name: name,
      gender: _gender,
      phoneOrInsta:
          _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
      location:
          _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
      mbti:
          _mbtiController.text.trim().isEmpty
              ? null
              : _mbtiController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (success && mounted) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('회원가입 완료! 로그인 해주세요.')));
      Navigator.pop(context, true); // 회원가입 후 돌아가기
    } else {
      setState(() => _error = '회원가입 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: '아이디*'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호*'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호 확인*'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '이름*'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: '성별*'),
              items: const [
                DropdownMenuItem(value: 'M', child: Text('남성')),
                DropdownMenuItem(value: 'F', child: Text('여성')),
              ],
              onChanged: (v) => setState(() => _gender = v ?? 'M'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: '연락처 / 인스타'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: '지역'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _mbtiController,
              decoration: const InputDecoration(labelText: 'MBTI'),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _register,
                  child: const Text('회원가입'),
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
