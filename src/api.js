const express = require('express');

module.exports = (db) => {
  const router = express.Router();

  router.get('/info', (req, res) => {
    res.status(200).json({
      version: process.env.APP_VERSION || '1.0.0',
      deployedAt: process.env.DEPLOYED_AT || new Date().toISOString(),
      nodeVersion: process.version
    });
  });

  router.get('/data', (req, res) => {
    res.status(200).json({
      items: ['Apple', 'Banana', 'Cherry'],
      total: 3,
      timestamp: new Date().toISOString()
    });
  });

  router.post('/login', (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        message: 'Username and password are required'
      });
    }

    const query = 'INSERT INTO users (username, password) VALUES (?, ?)';

    db.query(query, [username, password], (err) => {
      if (err) {
        console.error('DB insert error:', err.message);
        return res.status(500).json({
          message: 'Database error'
        });
      }

      return res.status(201).json({
        message: 'Login data saved successfully'
      });
    });
  });

  return router;
};
