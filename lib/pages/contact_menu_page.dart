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
      _startDrawAnimationAndFetch();
    }
  }

  /// 2. 애니메이션을 보여주면서 백그라운드에서 연락처를 가져옵니다.
  Future<void> _startDrawAnimationAndFetch() async {
    // 배경을 흐리게 하고 애니메이션을 보여주는 다이얼로그 표시
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

    // 3. 실제 연락처를 가져오는 API 호출
    final user = context.read<AuthProvider>().user;
    if (user == null || user.location == null || user.location!.isEmpty) {
      Navigator.pop(context); // 애니메이션 다이얼로그 닫기
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

    // API 호출과 최소 지연 시간을 동시에 실행하여 애니메이션이 충분히 보이도록 보장
    final results = await Future.wait([
      _api.drawContact(user.location!, user.gender),
      Future.delayed(const Duration(milliseconds: 2500)), // 최소 2.5초 대기
    ]);

    final c = results[0] as Contact?;

    if (!mounted) return;
    Navigator.pop(context); // 애니메이션 다이얼로그 닫기

    if (c != null) {
      // 4-1. 성공 시 결과 표시
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
      // 4-2. 실패 시 결과 표시
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
