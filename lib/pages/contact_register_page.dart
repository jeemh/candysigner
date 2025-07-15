import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ContactRegisterPage extends StatefulWidget {
  const ContactRegisterPage({super.key});

  @override
  State<ContactRegisterPage> createState() => _ContactRegisterPageState();
}

class _ContactRegisterPageState extends State<ContactRegisterPage> {
  final _introController = TextEditingController();
  final _contactController = TextEditingController();
  String _location = '서울';
  final _mbtiController = TextEditingController();
  String? _error;
  bool _isLoading = false;
  final ApiService _api = ApiService();

  Future<void> _submit() async {
    final intro = _introController.text.trim();
    final contact = _contactController.text.trim();
    if (intro.isEmpty || contact.isEmpty) {
      setState(() => _error = '소개와 연락처를 입력하세요');
      return;
    }
    final userIdStr = await const FlutterSecureStorage().read(key: 'user_id');
    if (userIdStr == null) {
      setState(() => _error = '로그인 정보가 없습니다');
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() => _error = '로그인 정보가 없습니다');
      return;
    }

    setState(() => _isLoading = true);
    final success = await _api.createContact(
      userId: int.parse(userIdStr),
      intro: intro,
      contactValue: contact,
      gender: user.gender,
      location: _location,
      mbti:
          _mbtiController.text.trim().isEmpty
              ? null
              : _mbtiController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('연락처 등록 완료')));
      Navigator.pop(context);
    } else {
      setState(() => _error = '등록 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('연락처 등록')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _introController,
              decoration: const InputDecoration(labelText: '한 줄 소개*'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(labelText: '연락처/인스타*'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _location,
              decoration: const InputDecoration(labelText: '지역'),
              items: const [
                DropdownMenuItem(value: '서울', child: Text('서울')),
                DropdownMenuItem(value: '경기남부', child: Text('경기남부')),
                DropdownMenuItem(value: '경기북부', child: Text('경기북부')),
                DropdownMenuItem(value: '그 외', child: Text('그 외')),
              ],
              onChanged: (v) => setState(() => _location = v ?? '서울'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _mbtiController,
              decoration: const InputDecoration(labelText: 'MBTI'),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: const Text('등록')),
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
