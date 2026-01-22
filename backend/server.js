/**
 * ================================================================
 * WARNING: THIS EXPRESS SERVER IS DEPRECATED AND MUST NOT BE USED
 * ================================================================
 * 
 * CRITICAL ARCHITECTURAL DECISION:
 * This Node.js/Express backend has been OFFICIALLY DEPRECATED.
 * 
 * The Laravel backend (backend-laravel/) is the ONLY authorized 
 * API endpoint for this government system.
 * 
 * REASONS FOR DEPRECATION:
 * 1. Dual-backend architecture creates multiple authentication surfaces
 * 2. Security audit requirements demand single source of truth
 * 3. Government compliance requires centralized access control
 * 4. Laravel provides superior audit logging and RBAC
 * 
 * ACTION REQUIRED:
 * - DO NOT start this server
 * - DO NOT add new endpoints here
 * - ALL mobile/client apps MUST connect to Laravel API only
 * - Use Laravel backend-laravel/ at http://localhost:8000/api
 * 
 * Date Deprecated: January 22, 2026
 * ================================================================
 */

process.exit(1); // Prevent accidental execution

// ==================== DEPRECATED CODE BELOW ====================
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.send('Hello from JEBOLMobile Backend!');
});

// Routes
app.use('/api/users', require('./routes/users'));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));