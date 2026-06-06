const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const db = require('../db');
const authMiddleware = require('../middleware/auth');

// Multer setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, Date.now() + path.extname(file.originalname)),
});
const upload = multer({ storage });

const BASE_URL = 'http://192.168.1.9:3000';

// GET /items
router.get('/', async (req, res) => {
  try {
    const { category, type, search } = req.query;
    let query = 'SELECT * FROM items WHERE 1=1';
    const params = [];

    if (category) { query += ' AND category = ?'; params.push(category); }
    if (type) { query += ' AND type = ?'; params.push(type); }
    if (search) { query += ' AND name LIKE ?'; params.push(`%${search}%`); }

    const [rows] = await db.query(query, params);
    const items = rows.map(item => ({
      ...item,
      image: item.image ? `${BASE_URL}/uploads/${item.image}` : null,
    }));
    return res.json({ success: true, data: items });
  } catch (err) {
    return res.json({ success: false, message: 'Server error: ' + err.message });
  }
});

// GET /items/:id
router.get('/:id', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM items WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.json({ success: false, message: 'Item not found' });
    const item = {
      ...rows[0],
      image: rows[0].image ? `${BASE_URL}/uploads/${rows[0].image}` : null,
    };
    return res.json({ success: true, data: item });
  } catch (err) {
    return res.json({ success: false, message: 'Server error: ' + err.message });
  }
});

// POST /items (admin)
router.post('/', authMiddleware, upload.single('image'), async (req, res) => {
  try {
    const { name, category, type, stat, description, stock, price } = req.body;
    if (!name || !category || !type || !stock || !price) {
      return res.json({ success: false, message: 'Required fields missing' });
    }
    const image = req.file ? req.file.filename : null;
    await db.query(
      'INSERT INTO items (name, category, type, stat, description, stock, image, price) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [name, category, type, stat, description, stock, image, price]
    );
    return res.json({ success: true, message: 'Item created successfully' });
  } catch (err) {
    return res.json({ success: false, message: 'Server error: ' + err.message });
  }
});

// PUT /items/:id (admin)
router.put('/:id', authMiddleware, upload.single('image'), async (req, res) => {
  try {
    const { name, category, type, stat, description, stock, price } = req.body;
    const [existing] = await db.query('SELECT * FROM items WHERE id = ?', [req.params.id]);
    if (existing.length === 0) return res.json({ success: false, message: 'Item not found' });

    const image = req.file ? req.file.filename : existing[0].image;
    await db.query(
      'UPDATE items SET name=?, category=?, type=?, stat=?, description=?, stock=?, image=?, price=? WHERE id=?',
      [name, category, type, stat, description, stock, image, price, req.params.id]
    );
    return res.json({ success: true, message: 'Item updated successfully' });
  } catch (err) {
    return res.json({ success: false, message: 'Server error: ' + err.message });
  }
});

// DELETE /items/:id (admin)
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const [existing] = await db.query('SELECT * FROM items WHERE id = ?', [req.params.id]);
    if (existing.length === 0) return res.json({ success: false, message: 'Item not found' });
    await db.query('DELETE FROM items WHERE id = ?', [req.params.id]);
    return res.json({ success: true, message: 'Item deleted successfully' });
  } catch (err) {
    return res.json({ success: false, message: 'Server error: ' + err.message });
  }
});

module.exports = router;