const express = require('express');
const router = express.Router();
const db = require('../db');
const authMiddleware = require('../middleware/auth');

const BASE_URL = 'http://192.168.1.9:3000';

// POST /buy
router.post('/buy', authMiddleware, async (req, res) => {
  try {
    const { item_id, quantity } = req.body;
    const userId = req.user.id;

    if (!item_id || !quantity || quantity < 1) {
      return res.json({ success: false, message: 'Invalid request' });
    }

    const [items] = await db.query('SELECT * FROM items WHERE id = ?', [item_id]);
    if (items.length === 0) return res.json({ success: false, message: 'Item not found' });

    const item = items[0];
    if (item.stock < quantity) {
      return res.json({ success: false, message: 'Insufficient stock' });
    }

    const [users] = await db.query('SELECT * FROM users WHERE id = ?', [userId]);
    const user = users[0];
    const totalPrice = item.price * quantity;

    if (user.mora < totalPrice) {
      return res.json({ success: false, message: 'Insufficient mora' });
    }

    await db.query('UPDATE users SET mora = mora - ? WHERE id = ?', [totalPrice, userId]);
    await db.query('UPDATE items SET stock = stock - ? WHERE id = ?', [quantity, item_id]);

    // Simpan hanya filename, bukan full URL
    const imageFilename = item.image
        ? item.image.replace(/^.*\/uploads\//, '')
        : null;

    await db.query(
      'INSERT INTO transactions (user_id, item_id, item_name, item_image, item_type, quantity, total_price) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [userId, item_id, item.name, imageFilename, item.type, quantity, totalPrice]
    );

    const [updatedUser] = await db.query('SELECT mora FROM users WHERE id = ?', [userId]);
    return res.json({
      success: true,
      message: 'Purchase successful',
      data: { mora: updatedUser[0].mora },
    });
  } catch (err) {
    return res.json({ success: false, message: 'Server error: ' + err.message });
  }
});

// GET /transactions/my
router.get('/transactions/my', authMiddleware, async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT t.*, i.type as item_type 
       FROM transactions t
       LEFT JOIN items i ON t.item_id = i.id
       WHERE t.user_id = ? 
       ORDER BY t.created_at DESC`,
      [req.user.id]
    );
    const data = rows.map(t => ({
      ...t,
      item_image: t.item_image
        ? `${BASE_URL}/uploads/${t.item_image.replace(/^.*\/uploads\//, '')}`
        : null,
    }));
    return res.json({ success: true, data });
  } catch (err) {
    return res.json({ success: false, message: 'Server error: ' + err.message });
  }
});

// GET /transactions/all (admin)
router.get('/transactions/all', authMiddleware, async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT t.*, i.type as item_type,
              u.name as user_name, u.email as user_email
       FROM transactions t
       LEFT JOIN items i ON t.item_id = i.id
       LEFT JOIN users u ON t.user_id = u.id
       ORDER BY t.created_at DESC`
    );
    const data = rows.map(t => ({
      ...t,
      item_image: t.item_image
        ? `${BASE_URL}/uploads/${t.item_image.replace(/^.*\/uploads\//, '')}`
        : null,
    }));
    return res.json({ success: true, data });
  } catch (err) {
    return res.json({ success: false, message: 'Server error: ' + err.message });
  }
});

module.exports = router;