# Railway Deployment Guide - JEBOL Backend (Laravel)

## ⚡ Quick Setup (5 minutes)

### 1. **Connect Repository to Railway**
```bash
# Login to Railway CLI
railway login

# Link project
cd backend-laravel
railway link

# View environment variables
railway variables
```

### 2. **Add Database Plugin**
- Go to your Railway project dashboard
- Click "+ Create" → "MySQL"
- Railway automatically creates these env vars:
  - `DB_HOST`
  - `DB_PORT`
  - `DB_DATABASE`
  - `DB_USERNAME`
  - `DB_PASSWORD`

### 3. **Set Required Environment Variables**
```bash
railway variables set APP_KEY="base64:YOUR_GENERATED_KEY"
railway variables set APP_URL="https://your-domain.railway.app"
railway variables set FRONTEND_URL="https://your-mobile-app-url"
```

To generate APP_KEY locally:
```bash
php artisan key:generate --show
```

### 4. **Deploy**
```bash
# Push to your repository
git push origin main

# Railway auto-deploys on push, or manually trigger:
railway deploy
```

---

## 🔧 Configuration Details

### Procfile
```
web: vendor/bin/heroku-php-apache2 public/
release: php artisan migrate --force
```
- **web process**: Starts Apache with PHP
- **release process**: Runs migrations on deployment (auto-runs before web starts)

### railway.json
- Builder: **nixpacks** (detects PHP/Laravel automatically)
- Start command: Apache with public/ as document root
- Replicas: 1 (scale up as needed)

### .railwayignore
Prevents bloat by excluding:
- Tests, docs, Postman collections
- Git metadata
- Non-essential markdown files
- Results in ~50MB smaller deployment

---

## 📋 Environment Variables Setup

### Automatic (Railway MySQL Plugin)
When you add MySQL, these are auto-populated:
```
DB_CONNECTION=mysql
DB_HOST=<auto>
DB_PORT=<auto>
DB_DATABASE=<auto>
DB_USERNAME=<auto>
DB_PASSWORD=<auto>
```

### Manual (Critical)
Must set these in Railway dashboard:
```
APP_KEY=base64:xxxxx              # Run: php artisan key:generate --show
APP_URL=https://your-domain.com  # Your Railway domain or custom domain
APP_ENV=production
APP_DEBUG=false
FRONTEND_URL=https://app-url.com  # Flutter mobile app URL
```

### Generated from .env.production
Automatically applied:
- Logging: warning level
- Session: secure cookies (HTTPS only)
- Cache: database-backed
- All security headers configured

---

## 🚀 Deployment Process

### Step-by-step:

1. **Local Verification** (optional but recommended)
```bash
cd backend-laravel
cp .env.example .env.production-local
php artisan migrate --env=production-local
php artisan test
```

2. **Commit & Push**
```bash
git add Procfile railway.json .env.production .railwayignore
git commit -m "chore: add Railway deployment configuration"
git push origin main
```

3. **Railway Deployment**
Railway auto-detects:
- Language: PHP 8.2+
- Framework: Laravel
- Build: `composer install` (done by nixpacks)
- Runtime: Apache with PHP

4. **Post-Deployment**
```bash
# Check deployment logs
railway logs

# Run artisan commands if needed
railway run "php artisan migrate"
railway run "php artisan cache:clear"

# SSH into production (if needed for debugging)
railway shell
```

---

## 🔍 Verification Checklist

After deployment:

```bash
# 1. Test API health
curl https://your-domain.railway.app/api/health

# 2. Test authentication
curl -X POST https://your-domain.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password"}'

# 3. Check database migration
railway run "php artisan migrate:status"

# 4. View logs for errors
railway logs --tail
```

Expected responses:
- Health endpoint: `{ "status": "ok" }`
- Login: `{ "access_token": "..." }`
- Migrations: All "yes"

---

## 📊 Performance & Scaling

### Default (1 replica)
- CPUs: Shared
- Memory: 0.5GB
- Bandwidth: 100GB/month
- Suitable for: Testing, staging, <10k requests/day

### Scale Up (Production)
1. In Railway dashboard → Generational settings
2. Choose "Eco" or "Standard" plan
3. Increase replicas for load balancing:
   ```
   # Edit railway.json:
   "numReplicas": 3
   ```

### Database Optimization
- Add read replicas if needed
- Enable query caching via Redis
- Monitor slow queries: `php artisan tinker`

---

## 🛡️ Security Checklist

### Before Going Live:

- [ ] APP_KEY set to unique value
- [ ] APP_DEBUG=false in production env
- [ ] APP_URL = actual domain (not localhost)
- [ ] FRONTEND_URL = exact mobile app URL (no wildcard)
- [ ] SESSION_SECURE_COOKIE=true
- [ ] DB credentials from Railway (auto-managed, never in code)
- [ ] SSL certificate: Railway provides free auto-SSL
- [ ] Rate limiting configured in middleware
- [ ] CORS restrictions enabled

### Government Compliance:
- [ ] Audit logging enabled (ENABLE_AUDIT_LOG=true)
- [ ] Sessions encrypted (SESSION_ENCRYPT=true)
- [ ] Password hashing: BCRYPT_ROUNDS=12
- [ ] Token expiration: ACCESS_TOKEN_TTL=60 (short-lived)
- [ ] Database backups: Railway provides daily backups

---

## 🐛 Troubleshooting

### "502 Bad Gateway"
```bash
# Check application logs
railway logs

# Likely causes:
# 1. APP_KEY missing: railway variables set APP_KEY="..."
# 2. DB connection failed: Ensure MySQL plugin connected
# 3. Migration failed: railway run "php artisan migrate:status"
```

### "500 Internal Server Error"
```bash
# Check error logs
railway logs -e PHP_ERROR

# Clear cache
railway run "php artisan cache:clear"
railway run "php artisan config:cache"

# Restart service
railway redeploy
```

### "CORS errors from mobile app"
```bash
# Verify FRONTEND_URL matches exactly
railway variables get FRONTEND_URL

# Update if needed:
railway variables set FRONTEND_URL="https://your-exact-app-url"
```

### Database connection issues
```bash
# Test database connection
railway run "php artisan db:show"

# Verify credentials in env
railway variables get | grep DB_
```

---

## 📝 Custom Domain Setup

### Add Your Domain:

1. **In Railway Dashboard**:
   - Project → Settings
   - Custom Domain → Add Domain
   - Enter: `api.jebol.go.id`

2. **DNS Configuration** (at your registrar):
   - Type: `CNAME`
   - Name: `api`
   - Value: `railway.app` (or provided by Railway)
   - TTL: 3600

3. **Verify**:
   ```bash
   nslookup api.jebol.go.id
   # Should resolve to Railway's IP
   ```

---

## 📞 Support & Monitoring

### Railway CLI Commands:
```bash
railway logs                    # View deployment logs
railway variables              # List all env vars
railway run "command"          # Execute artisan command
railway shell                  # SSH into container
railway redeploy               # Force redeploy
railway down                   # Take service offline
```

### External Monitoring:
- Uptime monitoring: Use services like UptimeRobot
- Error tracking: Integrate Sentry (update .env)
- Performance: Use Laravel Telescope (production-safe)

---

## ✅ Deployment Summary

Your backend is now ready for Railway:

| Item | Status |
|------|--------|
| Procfile | ✓ Created (Apache + PHP) |
| railway.json | ✓ Created (auto-config) |
| .env.production | ✓ Created (security-hardened) |
| Migrations | ✓ Auto-run on deploy |
| Security | ✓ HTTPS/Sessions configured |
| Database | ✓ Manual plugin setup (one click) |

**Next Steps**: 
1. Create Railway account: railway.app
2. Connect GitHub repository
3. Add MySQL plugin
4. Set APP_KEY env variable
5. Deploy!

Questions? See: [backend-laravel/README.md](README.md)
