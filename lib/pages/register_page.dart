import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  final String? initialUsername;
  final String? initialName;

  const RegisterPage({super.key, this.initialUsername, this.initialName});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _gender = 'M';
  String? _selectedLocation;
  String? _selectedMbti;
  String? _error;
  bool _isLoading = false;
  final ApiService _api = ApiService();

  final List<String> _locations = ['서울', '경기남부', '경기북부', '그 외'];
  final List<String> _mbtiTypes = [
    'ISTJ',
    'ISFJ',
    'INFJ',
    'INTJ',
    'ISTP',
    'ISFP',
    'INFP',
    'INTP',
    'ESTP',
    'ESFP',
    'ENFP',
    'ENTP',
    'ESTJ',
    'ESFJ',
    'ENFJ',
    'ENTJ',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialUsername != null) {
      _usernameController.text = widget.initialUsername!;
    }
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final username = _usernameController.text.trim();
    final name = _nameController.text.trim();

    if ([username, name].any((e) => e.isEmpty)) {
      setState(() => _error = '필수 항목을 모두 입력하세요');
      return;
    }
    setState(() => _isLoading = true);
    final success = await _api.register(
      username: username,
      name: name,
      gender: _gender,
      phoneOrInsta:
          _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
      location: _selectedLocation,
      mbti: _selectedMbti,
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
              readOnly: widget.initialUsername != null, // 구글 가입 시 아이디 수정 불가
              decoration: const InputDecoration(labelText: '아이디*'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              readOnly: widget.initialName != null,
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
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              hint: const Text('지역 선택'),
              decoration: const InputDecoration(labelText: '지역'),
              items:
                  _locations.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (v) => setState(() => _selectedLocation = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedMbti,
              hint: const Text('MBTI 선택'),
              decoration: const InputDecoration(labelText: 'MBTI'),
              items:
                  _mbtiTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (v) => setState(() => _selectedMbti = v),
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
