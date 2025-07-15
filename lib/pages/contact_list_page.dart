import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/contact.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  String _location = '서울';
  final ApiService _api = ApiService();
  Contact? _contact;
  bool _loading = false;

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final loc = _location;
    final userGender = context.read<AuthProvider>().user?.gender ?? '';
    final c = await _api.drawContact(loc, userGender);
    setState(() {
      _contact = c;
      _loading = false;
    });
    if (c != null && context.mounted) {
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
    } else if (c == null && context.mounted) {
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
    return Scaffold(
      appBar: AppBar(title: const Text('연락처 뽑기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
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
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _fetch, child: const Text('검색')),
              ],
            ),
            if (_loading) const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
