// server.js
const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');
const cors = require('cors');
const dotenv = require('dotenv');
const axios = require('axios');
dotenv.config();

const app = express();
app.use(bodyParser.json());
app.use(cors());

// 비밀번호 해싱용 옵션
const SALT_ROUNDS = 10;

// MySQL 연결 정보
const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT || 3306),
};

const pool = mysql.createPool(dbConfig);

/* -------------------------- 회원가입 -------------------------- */
app.post('/auth/register', async (req, res) => {
  const { username, name, phone_or_insta, gender, location, mbti } =
    req.body;

  if (!username || !name || !gender || !phone_or_insta || !location || !mbti) {
    return res
      .status(400)
      .json({ error: '모든 항목을 입력해주세요.' });
  }

  try {
    // 이미 존재하는지 확인
    const [exist] = await pool.execute(
      'SELECT id FROM users WHERE username = ? LIMIT 1',
      [username]
    );
    if (exist.length > 0) {
      return res.status(409).json({ error: '이미 사용 중인 아이디입니다.' });
    }

    const [result] = await pool.execute(
      `INSERT INTO users (username, name, phone_or_insta, gender, location, mbti)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        username,
        name,
        phone_or_insta,
        gender,
        location,
        mbti,
      ]
    );

    res.status(201).json({ id: result.insertId, username, name });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '회원가입 실패' });
  }
});

/* -------------------------- 구글 로그인 -------------------------- */
app.post('/auth/google', async (req, res) => {
  const { idToken } = req.body;

  if (!idToken) {
    return res.status(400).json({ error: 'ID Token is required' });
  }

  try {
    // 1. 구글 API로 ID Token 검증 및 사용자 정보 조회
    const googleRes = await axios.get(
      `https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`
    );
    const { email, name, gender } = googleRes.data;

    // 2. DB에서 사용자 확인
    const [rows] = await pool.execute(
      'SELECT * FROM users WHERE username = ? LIMIT 1',
      [email]
    );

    if (rows.length > 0) {
      // 이미 가입된 사용자
      const user = rows[0];
      // 비밀번호 제외하고 응답
      if (user.password) delete user.password;
      res.json(user);
    } else {
      // 신규 가입 필요: 클라이언트에게 가입 페이지로 이동하라는 신호와 기본 정보 전달
      res.json({ needsRegister: true, username: email, name: name, gender });
    }

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Google Login Failed' });
  }
});

// 연락처 목록 조회 (지역 필터)
app.get('/contacts', async (req, res) => {
  const { location, excludeGender } = req.query;
  try {
    let sql = 'SELECT * FROM contacts';
    const params = [];
    if (location) {
      sql += ' WHERE location = ?';
      params.push(location);
    }
    if (excludeGender) {
      if (params.length === 0) sql += ' WHERE';
      else sql += ' AND';
      sql += ' gender <> ?';
      params.push(excludeGender);
    }
    sql += ' ORDER BY created_at ASC';
    const [rows] = await pool.execute(sql, params);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch contacts' });
  }
});

// 연락처 등록
app.post('/contacts', async (req, res) => {
  const { user_id, intro, contact_value, location, mbti, gender } = req.body;
  if (!user_id || !intro || !contact_value || !gender) {
    return res.status(400).json({ error: 'user_id, intro, contact_value are required' });
  }
  try {
    const [result] = await pool.execute(
      'INSERT INTO contacts (user_id, intro, contact_value, location, mbti, gender) VALUES (?, ?, ?, ?, ?, ?)',
      [user_id, intro, contact_value, location, mbti, gender]
    );
    res.status(201).json({ id: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create contact' });
  }
});

// 연락처 삭제 (id 기준)
app.delete('/contacts/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.execute('DELETE FROM contacts WHERE id = ?', [id]);
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete contact' });
  }
});

app.listen(3000, () => {
  console.log('서버가 3000번 포트에서 실행 중입니다.');
});
