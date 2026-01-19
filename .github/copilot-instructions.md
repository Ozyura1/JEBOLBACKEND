<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

## JEBOL Project - Backend Setup Complete

### Completed Tasks
- [x] Laravel project scaffolded at `backend-laravel/`
- [x] Laravel Sanctum installed (v4.2.3)
- [x] Custom users migration created with:
  - Single role ENUM (SUPER_ADMIN, ADMIN_KTP, ADMIN_IKD, ADMIN_PERKAWINAN, RT)
  - UUID column for public API references
  - Username-based authentication
  - is_active flag
- [x] Password reset tokens migration created
- [x] Sanctum personal_access_tokens migration published
- [x] .env configured for MySQL (Laragon)
- [x] README.md created with setup instructions

### Database Migrations Created
1. `2026_01_16_000000_create_users_table.php` - Users with role ENUM
2. `2026_01_16_000010_create_password_reset_tokens_table.php` - Password resets
3. `2026_01_16_080535_create_personal_access_tokens_table.php` - Sanctum tokens

### Next Steps
1. Fix MySQL authentication in Laragon (see README)
2. Run migrations: `php artisan migrate`
3. Create AuthController (login/logout endpoints)
4. Create role-based middleware
5. Create API routes structure
6. Create workflow migrations (ktp_requests, ikd_activations, marriages)

### Project Structure
```
JEBOLMobile/
├── .github/
│   └── copilot-instructions.md
├── backend/ (Node.js - legacy)
└── backend-laravel/ (NEW - Laravel API)
    ├── database/migrations/
    ├── README.md
    └── .env (configured)
```