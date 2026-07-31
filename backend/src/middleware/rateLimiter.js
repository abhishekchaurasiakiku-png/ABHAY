const rateLimit = require('express-rate-limit');

/**
 * Rate limiters for SafeHer-AI API endpoints.
 *
 * Different tiers for different sensitivity levels:
 * - Auth: strict (prevents brute-force)
 * - SOS: moderate (prevents spam but allows rapid retries)
 * - General: permissive
 */

// ─── Auth Rate Limiter ────────────────────────────────────────
// 10 attempts per 15 minutes per IP
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10,
  message: {
    error: 'Too many authentication attempts. Please try again in 15 minutes.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// ─── SOS Rate Limiter ─────────────────────────────────────────
// 5 per minute per IP (allows rapid retries but prevents abuse)
const sosLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 5,
  message: {
    error: 'Too many SOS requests. Please wait before retrying.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// ─── General API Rate Limiter ─────────────────────────────────
// 100 per 15 minutes per IP
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: {
    error: 'Too many requests. Please slow down.',
  },
  standardHeaders: true,
  legacyHeaders: false,
});

module.exports = {
  authLimiter,
  sosLimiter,
  generalLimiter,
};
