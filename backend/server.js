const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
const authRoutes = require('./routes/auth');
const itemRoutes = require('./routes/items');
const transactionRoutes = require('./routes/transactions');
const topupRoutes = require('./routes/topup');
const profileRoutes = require('./routes/profile');

app.use('/auth', authRoutes);
app.use('/items', itemRoutes);
app.use('/', transactionRoutes);
app.use('/topup', topupRoutes);
app.use('/profile', profileRoutes);

// Test route
app.get('/', (req, res) => {
  res.json({ message: 'Genshin Import API is running!' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});