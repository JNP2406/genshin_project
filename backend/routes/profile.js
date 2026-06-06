const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const db = require('../db');
const authMiddleware = require('../middleware/auth');

const BASE_URL = 'http://10.135.100.84:3000';

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, Date.now() + path.extname(file.originalname)),
});
const upload = multer({ storage });

// PUT /profile
router.put('/', authMiddleware, upload.fields([
  { name: 'profile_picture', maxCount: 1 },
  { name: 'cover_photo', maxCount: 1 },
]), async (req, res) => {
  try {
    const { name, email, bio, remove_profile_picture, remove_cover_photo } = req.body;
    const userId = req.user.id;

    const [existing] = await db.query('SELECT * FROM users WHERE id = ?', [userId]);
    if (existing.length === 0) return res.json({ success: false, message: 'User not found' });

    // Handle profile picture
    let profilePicture;
    if (req.files?.profile_picture) {
      profilePicture = req.files.profile_picture[0].filename;
    } else if (remove_profile_picture === 'true') {
      profilePicture = null;
    } else {
      profilePicture = existing[0].profile_picture;
    }

    // Handle cover photo
    let coverPhoto;
    if (req.files?.cover_photo) {
      coverPhoto = req.files.cover_photo[0].filename;
    } else if (remove_cover_photo === 'true') {
      coverPhoto = null;
    } else {
      coverPhoto = existing[0].cover_photo;
    }

    await db.query(
      'UPDATE users SET name=?, email=?, bio=?, profile_picture=?, cover_photo=? WHERE id=?',
      [name || existing[0].name, email || existing[0].email, bio, profilePicture, coverPhoto, userId]
    );

    const profilePictureUrl = profilePicture
      ? `${BASE_URL}/uploads/${profilePicture}`
      : null;
    const coverPhotoUrl = coverPhoto
      ? `${BASE_URL}/uploads/${coverPhoto}`
      : null;

    return res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        profile_picture: profilePictureUrl,
        cover_photo: coverPhotoUrl,
      },
    });
  } catch (err) {
    return res.json({ success: false, message: 'Server error: ' + err.message });
  }
});

module.exports = router;