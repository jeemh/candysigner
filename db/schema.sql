-- 유저 테이블
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE, -- 로그인용 아이디
  password VARCHAR(255) NOT NULL,       -- 암호화된 비밀번호
  name VARCHAR(100) NOT NULL,           -- 이름
  phone_or_insta VARCHAR(255),          -- 연락처 또는 인스타 ID
  gender ENUM('M','F') NOT NULL,
  location VARCHAR(100),               -- 사는 곳
  mbti VARCHAR(4),
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 연락처(소개) 테이블
CREATE TABLE contacts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  intro TEXT,                          -- 한 줄 소개
  contact_value VARCHAR(255) NOT NULL,  -- 공개할 연락처/인스타
  gender ENUM('M','F') NOT NULL,
  location VARCHAR(100),               -- 사용자 위치(필터 용도)
  mbti VARCHAR(4),                     -- MBTI 표시
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_location (location)
); 