require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const http = require('http');
const { WebSocketServer } = require('ws');
const path = require('path');
const fs = require('fs');

// Routes
const authRoutes = require('./routes/authRoutes');
const sosRoutes = require('./routes/sosRoutes');
const userRoutes = require('./routes/userRoutes');
const incidentRoutes = require('./routes/incidentRoutes');
const safetyRoutes = require('./routes/safetyRoutes');

// Services
const { initializeWebSocket } = require('./services/websocketService');

const app = express();
const server = http.createServer(app);

// ─── Middleware ──────────────────────────────────────────────
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Ensure uploads directory exists
const uploadDir = process.env.UPLOAD_DIR || './uploads';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}
app.use('/uploads', express.static(path.join(__dirname, '..', uploadDir)));

// ─── Routes ─────────────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/sos', sosRoutes);
app.use('/api/users', userRoutes);
app.use('/api/incidents', incidentRoutes);
app.use('/api/safety', safetyRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'SafeHer-AI Backend',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// ─── Error Handler ──────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('[Error]', err.message);
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error',
  });
});

// ─── WebSocket ──────────────────────────────────────────────
const wss = new WebSocketServer({ server, path: '/tracking' });
initializeWebSocket(wss);

// ─── MongoDB Connection & Server Start ──────────────────────
const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/safeher-ai';

mongoose.connect(MONGODB_URI)
  .then(() => {
    console.log('✅ MongoDB connected');

    server.listen(PORT, () => {
      console.log(`🚀 SafeHer-AI Backend running on port ${PORT}`);
      console.log(`📡 WebSocket server ready at ws://localhost:${PORT}/tracking`);
    });
  })
  .catch((err) => {
    console.error('❌ MongoDB connection failed:', err.message);
    process.exit(1);
  });

module.exports = app;
