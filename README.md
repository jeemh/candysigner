# 🍬 Candy Signer

> 내 지역에서 랜덤으로 새로운 인연을 찾아보세요!
>
> **Candy Signer**는 사용자가 자신의 연락처를 '사탕(Candy)'처럼 등록하고, 다른 사람의 사탕을 뽑아 교환하는 위치 기반 익명 연락처 교환 서비스입니다.

---

## ✨ 주요 기능

*   **회원가입 및 로그인**: 간단한 정보 입력으로 가입하고 서비스를 이용할 수 있습니다.
*   **프로필 설정**: 자신의 지역, MBTI, 성별 등 기본 프로필을 설정합니다.
*   **연락처 등록 (사탕 넣기)**: 자신을 어필할 한 줄 소개와 연락처(인스타 ID 등)를 '사탕'으로 만들어 등록합니다.
*   **연락처 뽑기 (사탕 뽑기)**: 내 프로필에 등록된 지역을 기반으로, 다른 사람이 등록한 '사탕'을 랜덤으로 하나 뽑습니다.
*   **안전한 교환**: 한 번 뽑힌 연락처는 다른 사람이 다시 뽑을 수 없도록 시스템에서 삭제됩니다.

## ⚙️ 기술 스택

| 구분      | 기술                               |
| :-------- | :--------------------------------- |
| **Frontend**  | Flutter, Provider                  |
| **Backend**   | Node.js, Express.js                |
| **Database**  | MySQL                              |
| **ETC**       | bcrypt (비밀번호 암호화)           |

## 🚀 시작하기

프로젝트를 로컬 환경에서 실행하는 방법입니다.

### 1. 사전 준비

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) 설치
*   [Node.js](https://nodejs.org/) 설치
*   [MySQL](https://dev.mysql.com/downloads/mysql/) 설치 및 실행

### 2. 백엔드 서버 실행

```bash
# 1. 프로젝트 루트 디렉토리로 이동
cd /path/to/candysigner

# 2. 필요한 패키지 설치
npm install

# 3. .env 파일 생성 및 데이터베이스 정보 입력
# DB_HOST, DB_USER, DB_PASSWORD, DB_NAME, DB_PORT 등을 설정합니다.

# 4. 서버 실행
node server.js

# 서버가 3000번 포트에서 실행됩니다.
```

### 3. 데이터베이스 테이블 생성

MySQL에 접속하여 아래 쿼리를 실행해 `users`와 `contacts` 테이블을 생성합니다.

```sql
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  gender CHAR(1) NOT NULL,
  phone_or_insta VARCHAR(255),
  location VARCHAR(255),
  mbti VARCHAR(4),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE contacts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  intro TEXT NOT NULL,
  contact_value VARCHAR(255) NOT NULL,
  location VARCHAR(255),
  gender CHAR(1) NOT NULL,
  mbti VARCHAR(4),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### 4. Flutter 앱 실행

```bash
# 1. Flutter 프로젝트의 의존성 패키지 설치
flutter pub get

# 2. 앱 실행 (Android/iOS 시뮬레이터 또는 실제 기기)
flutter run
```
