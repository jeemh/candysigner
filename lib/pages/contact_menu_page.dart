import 'package:candysigner/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../main.dart';
import 'contact_register_page.dart';
import '../services/api_service.dart';
import '../models/contact.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';

class ContactMenuPage extends StatefulWidget {
  const ContactMenuPage({super.key});

  @override
  State<ContactMenuPage> createState() => _ContactMenuPageState();
}

class _ContactMenuPageState extends State<ContactMenuPage> {
  final ApiService _api = ApiService();
  int? _availableContactsCount;

  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 첫 프레임에서 연락처 개수를 가져옵니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAvailableContactsCount();
    });
  }

  /// 뽑을 수 있는 연락처의 개수를 가져와 상태를 업데이트합니다.
  Future<void> _fetchAvailableContactsCount() async {
    final user = context.read<AuthProvider>().user;
    if (user == null || user.location == null || user.location!.isEmpty) return;

    final contacts = await _api.fetchNearbyContacts(
      user.location!,
      excludeGender: user.gender,
    );
    if (!mounted) return;
    setState(() => _availableContactsCount = contacts.length);
  }

  /// 1. 사용자에게 연락처 뽑기 실행 여부를 확인하는 다이얼로그를 표시합니다.
  Future<void> _showConfirmationDialog() async {
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
      // 2. 연락처 뽑기 전, 뽑을 대상이 있는지 먼저 확인
      final user = context.read<AuthProvider>().user;
      if (user == null || user.location == null || user.location!.isEmpty) {
        _showNoLocationInfoDialog();
        return;
      }

      // `fetchNearbyContacts`를 호출하여 연락처가 있는지 확인
      final availableContacts = await _api.fetchNearbyContacts(
        user.location!,
        excludeGender: user.gender,
      );

      if (!mounted) return;

      if (availableContacts.isNotEmpty) {
        // 뽑기 전 개수를 현재 상태에 반영
        setState(() => _availableContactsCount = availableContacts.length);
        // 뽑을 연락처가 있으면 애니메이션 시작
        _startDrawAnimationAndFetch(user);
      } else {
        // 뽑을 연락처가 없으면 바로 결과 표시
        _showNoContactsDialog();
      }
    }
  }

  /// 사용자 프로필에 지역 정보가 없을 때 표시하는 다이얼로그
  void _showNoLocationInfoDialog() {
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

  /// 3. 애니메이션을 보여주면서 백그라운드에서 연락처를 가져옵니다.
  Future<void> _startDrawAnimationAndFetch(User user) async {
    // 1. 애니메이션 다이얼로그를 먼저 보여줍니다.
    showDialog(
      context: context,
      barrierDismissible: false, // 로딩 중에는 닫을 수 없도록 설정
      barrierColor: Colors.black.withOpacity(0.5), // 반투명한 검은색 배경
      builder:
          (context) => BackdropFilter(
            // 배경 블러 효과
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Center(
                child: Lottie.asset(
                  'assets/animations/drawing_candy.json',
                  width: 350, // 애니메이션 크기 증가
                  height: 350, // 애니메이션 크기 증가
                ),
              ),
            ),
          ),
    );

    // 2. API 호출과 최소 지연 시간을 동시에 기다립니다.
    final results = await Future.wait([
      _api.drawContact(user.location!, user.gender),
      Future.delayed(const Duration(milliseconds: 2500)), // 최소 2.5초 대기
    ]);

    final c = results[0] as Contact?;

    if (!mounted) return;

    Navigator.pop(context); // 3. 애니메이션 다이얼로그를 닫습니다.

    // 4. API 결과에 따라 최종 다이얼로그를 보여줍니다.
    if (c != null) {
      // 연락처 뽑기 성공 시, 카운트를 1 감소시킵니다.
      setState(() {
        _availableContactsCount = (_availableContactsCount ?? 1) - 1;
      });
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
      // 뽑기 실패 시(그 사이에 다른 사람이 먼저 뽑아간 경우) 결과 표시
      _showNoContactsDialog();
    }
  }

  /// 뽑을 연락처가 없을 때 표시하는 다이얼로그
  void _showNoContactsDialog() {
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('연락처 메뉴'),
        actions: [
          // 뽑을 수 있는 연락처 개수 표시
          if (_availableContactsCount != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Chip(
                  label: Text('남은 사탕: $_availableContactsCount개'),
                  padding: const EdgeInsets.all(4),
                ),
              ),
            ),
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
