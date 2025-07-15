# 프로젝트 폴더 구조 (스켈레톤)

```
root/
├─ lib/
│  ├─ models/
│  │  ├─ user.dart
│  │  └─ contact.dart
│  ├─ pages/
│  │  ├─ register_page.dart          # 회원가입 페이지 (미구현)
│  │  ├─ contact_register_page.dart  # 연락처 등록 페이지 (미구현)
│  │  └─ contact_list_page.dart      # 주변 연락처 확인 페이지 (미구현)
│  └─ services/
│     └─ api_service.dart
├─ server.js                          # Node.js 서버
├─ db/
│  └─ schema.sql                      # MySQL 테이블 생성 스크립트
└─ README_PROJECT_STRUCTURE.md        # 현재 문서
```

## 개발 순서 제안

1. **DB 구축**: `schema.sql` 실행 → `users`, `contacts` 테이블 생성.
2. **Node.js 서버**: `server.js` 실행 → `/auth/google`, `/contacts` 엔드포인트 구현 확장.
3. **Flutter**:
   - `models/` 완성 (user, contact)
   - `services/api_service.dart`에서 서버 호출 테스트
   - `pages/` UI 구현 (참고 이미지 형태로 카드 스와이프 등)
4. **상태 관리**: `flutter_secure_storage`에 유저 정보 저장/삭제로 로그인 상태 유지.

> 각 파일은 스켈레톤이므로, 실제 로직/디자인을 채워가며 개발하세요. 