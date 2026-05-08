const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// This is the health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION || '1.0.0'
  });
});

app.get('/', (req, res) => {
  res.status(200).json({
    message: 'Prod-Ready Application is running!',
    environment: process.env.NODE_ENV || 'development',
    uptime: process.uptime()
  });
});

app.get('/api/info', (req, res) => {
  res.status(200).json({
    app: 'Prod-Ready-Application',
    region: process.env.AWS_REGION || 'unknown',
    environment: process.env.NODE_ENV || 'development'
  });
});

// Only start the server if this file is run directly (not imported by tests)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  });
}

module.exports = app;