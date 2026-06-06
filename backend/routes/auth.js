const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');
require('dotenv').config();

function generateToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
}

function buildUserData(user, token) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    mora: user.mora,
    profile_picture: user.profile_picture
      ? `http://10.0.2.2:3000/uploads/${user.profile_picture}`
      : null,
    cover_photo: user.cover_photo
      ? `http://10.0.2.2:3000/uploads/${user.cover_photo}`
      : null,
    bio: user.bio,
    token: token,
  };
}

// POST /auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.json({ success: false, message: 'Email and password required' });
    }

    const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0) {
      return res.json({ success: false, message: 'Email not found' });
    }

    const user = rows[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.json({ success: false, message: 'Wrong password' });
    }

    const token = generateToken(user);
    await db.query('UPDATE users SET token = ? WHERE id = ?', [token, user.id]);

    return res.json({
      success: true,
      message: 'Login successful',
      data: buildUserData(user, token),
    });
  } catch (err) {
    return res.json({ success: false, message: 'Server error: ' + err.message });
  }
});

// POST /auth/register
router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
      return res.json({ success: false, message: 'All fields required' });
    }

    const [existing] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.json({ success: false, message: 'Email already registered' });
    }

    const hashed = await bcrypt.hash(password, 10);
    const [result] = await db.query(
      'INSERT INTO users (name, email, password, role, mora) VALUES (?, ?, ?, "user", 0)',
      [name, email, hashed]
    );

    const [newUser] = await db.query('SELECT * FROM users WHERE id = ?', [result.insertId]);
    const user = newUser[0];
    const token = generateToken(user);
    await db.query('UPDATE users SET token = ? WHERE id = ?', [token, user.id]);

    return res.json({
      success: true,
      message: 'Register successful',
      data: buildUserData(user, token),
    });
  } catch (err) {
    return res.json({ success: false, message: 'Server error: ' + err.message });
  }
});

// POST /auth/google
router.post('/google', async (req, res) => {
  try {
    const { name, email } = req.body;
    if (!email) {
      return res.json({ success: false, message: 'Email required' });
    }

    const [existing] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    let user;

    if (existing.length > 0) {
      user = existing[0];
    } else {
      const [result] = await db.query(
        'INSERT INTO users (name, email, password, role, mora) VALUES (?, ?, ?, "user", 0)',
        [name, email, '']
      );
      const [newUser] = await db.query('SELECT * FROM users WHERE id = ?', [result.insertId]);
      user = newUser[0];
    }

    const token = generateToken(user);
    await db.query('UPDATE users SET token = ? WHERE id = ?', [token, user.id]);

    return res.json({
      success: true,
      message: 'Google login successful',
      data: buildUserData(user, token),
    });
  } catch (err) {
    return res.json({ success: false, message: 'Server error: ' + err.message });
  }
});

module.exports = router;