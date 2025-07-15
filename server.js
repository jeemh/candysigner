// server.js
const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');
const cors = require('cors');
const dotenv = require('dotenv');
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
  const { username, password, name, phone_or_insta, gender, location, mbti } =
    req.body;

  if (!username || !password || !name || !gender) {
    return res
      .status(400)
      .json({ error: 'username, password, name, gender 는 필수입니다.' });
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

    const hashed = await bcrypt.hash(password, SALT_ROUNDS);

    const [result] = await pool.execute(
      `INSERT INTO users (username, password, name, phone_or_insta, gender, location, mbti)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        username,
        hashed,
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

/* -------------------------- 로그인 -------------------------- */
app.post('/auth/login', async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res
      .status(400)
      .json({ error: 'username, password 를 모두 입력하세요.' });
  }

  try {
    const [rows] = await pool.execute(
      'SELECT * FROM users WHERE username = ? LIMIT 1',
      [username]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: '존재하지 않는 계정입니다.' });
    }

    const user = rows[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: '비밀번호가 틀렸습니다.' });
    }

    // 성공: 비밀번호 제거 후 응답
    delete user.password;
    res.json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '로그인 실패' });
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
