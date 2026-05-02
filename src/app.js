const express = require('express');
const path    = require('path');
const mysql   = require('mysql2');

const app  = express();
const PORT = process.env.PORT || 3000;

// 🔥 MySQL Connection (using ENV variables)
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

db.connect(err => {
  if (err) {
    console.error('DB connection failed:', err);
  } else {
    console.log('Connected to MySQL DB');
  }
});

// Serve static files
app.use(express.static(path.join(__dirname, '..', 'public')));
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});

// Deployment info
app.get('/api/info', (req, res) => {
  res.json({
    version: process.env.APP_VERSION || '1.0.0',
    deployedAt: process.env.DEPLOYED_AT || new Date().toISOString(),
    nodeVersion: process.version,
  });
});

// Sample data
app.get('/api/data', (req, res) => {
  res.json({
    items: ['Apple', 'Banana', 'Cherry'],
    total: 3,
    timestamp: new Date().toISOString(),
  });
});

// 🔥 LOGIN API
app.post('/api/login', (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.json({ message: 'Username & Password required' });
  }

  const query = 'INSERT INTO users (username, password) VALUES (?, ?)';

  db.query(query, [username, password], (err, result) => {
    if (err) {
      console.error(err);
      return res.json({ message: 'DB error' });
    }
    res.json({ message: 'Login data saved successfully' });
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
