const express = require('express');
const path    = require('path');
 
const app  = express();
const PORT = process.env.PORT || 3000;
 
// Serve static files from /public
app.use(express.static(path.join(__dirname, '..', 'public')));
app.use(express.json());
 
// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', uptime: process.uptime() });
});
 
// Deployment info endpoint
app.get('/api/info', (req, res) => {
  res.json({
    version:    process.env.APP_VERSION || '1.0.0',
    deployedAt: process.env.DEPLOYED_AT || new Date().toISOString(),
    nodeVersion: process.version,
  });
});
 
// Sample data endpoint
app.get('/api/data', (req, res) => {
  res.json({
    items: ['Apple', 'Banana', 'Cherry'],
    total: 3,
    timestamp: new Date().toISOString(),
  });
});
 
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
 
module.exports = app;
