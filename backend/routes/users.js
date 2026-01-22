/**
 * ================================================================
 * DEPRECATED: DO NOT USE
 * ================================================================
 * This endpoint is part of the deprecated Node.js backend.
 * Use Laravel API endpoints instead: backend-laravel/routes/api.php
 * ================================================================
 */

const express = require('express');
const router = express.Router();

// Example route
router.get('/', (req, res) => {
  res.json({ message: 'Users endpoint' });
});

module.exports = router;