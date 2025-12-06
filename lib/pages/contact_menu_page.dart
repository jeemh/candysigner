import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../main.dart';
import 'contact_register_page.dart';
import '../services/api_service.dart';
import '../models/contact.dart';

class ContactMenuPage extends StatefulWidget {
  const ContactMenuPage({super.key});

  @override
  State<ContactMenuPage> createState() => _ContactMenuPageState();
}

class _ContactMenuPageState extends State<ContactMenuPage> {
  final ApiService _api = ApiService();
  bool _isLoading = false;

  /// 1. 사용자에게 연락처 뽑기 실행 여부를 확인하는 다이얼로그를 표시합니다.
  Future<void> _showConfirmationDialog() async {
    if (_isLoading) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('연락처 뽑기'),
            content: const Text('정말 연락처를 뽑으시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('확인'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      _fetchContact();
    }
  }

  /// 2. 실제 연락처를 가져오는 API를 호출하고 결과를 처리합니다.
  Future<void> _fetchContact() async {
    setState(() => _isLoading = true);

    final user = context.read<AuthProvider>().user;
    if (user == null || user.location == null || user.location!.isEmpty) {
      setState(() => _isLoading = false);
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('지역 정보 없음'),
                content: const Text('프로필에 지역 정보가 등록되어 있지 않습니다.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('확인'),
                  ),
                ],
              ),
        );
      }
      return;
    }

    final c = await _api.drawContact(user.location!, user.gender);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (c != null) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('연락처 추첨 결과'),
              content: Card(
                child: ListTile(
                  title: Text(c.intro),
                  subtitle: Text(
                    '${c.contactValue} • ${c.location ?? ''} ${c.mbti ?? ''}',
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
              ],
            ),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              content: const Text('해당 지역에 등록된 연락처가 없습니다'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('연락처 메뉴'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const StartPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null) ...[
              Text(
                '${user.username}  (${user.gender}, ${user.mbti ?? '-'})  ${user.phoneOrInsta ?? ''}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ContactRegisterPage(),
                    ),
                  ),
              child: const Text('연락처 등록'),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _showConfirmationDialog,
                child: const Text('연락처 뽑기'),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
