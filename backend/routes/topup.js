const express = require('express');
const router = express.Router();
const db = require('../db');
const authMiddleware = require('../middleware/auth');

// POST /topup
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { mora_amount, price } = req.body;
    const userId = req.user.id;

    if (!mora_amount || !price) {
      return res.json({ success: false, message: 'Invalid request' });
    }

    await db.query('UPDATE users SET mora = mora + ? WHERE id = ?', [mora_amount, userId]);
    await db.query(
      'INSERT INTO topup (user_id, mora_amount, price) VALUES (?, ?, ?)',
      [userId, mora_amount, price]
    );

    const [updated] = await db.query('SELECT mora FROM users WHERE id = ?', [userId]);
    return res.json({
      success: true,
      message: 'Top up successful',
      data: { mora: updated[0].mora },
    });
  } catch (err) {
    return res.json({ success: false, message: 'Server error: ' + err.message });
  }
});

module.exports = router;