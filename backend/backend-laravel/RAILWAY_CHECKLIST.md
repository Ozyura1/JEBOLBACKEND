# JEBOL Backend - Railway Deployment Checklist

## Pre-Deployment (Local)

### 1. Repository Setup
- [ ] All code committed to git
- [ ] `.env.production` file reviewed and correct
- [ ] `Procfile` exists in root
- [ ] `railway.json` exists in root
- [ ] `.railwayignore` exists in root
- [ ] Run: `git log --oneline | head -5` (verify recent commits)

### 2. Code Quality
- [ ] Tests passing: `php artisan test`
- [ ] No linting errors: `php artisan pint --check`
- [ ] Database migrations up-to-date: `php artisan migrate:status`
- [ ] No hardcoded credentials in code

### 3. Generate APP_KEY (Critical!)
```bash
php artisan key:generate --show
# Output: base64:xxxxx...
# Copy this value for Railway variables step
```

---

## Railway Dashboard Setup

### 1. Create Project
- [ ] Login to https://railway.app
- [ ] Click "New Project" → "Deploy from GitHub"
- [ ] Select your repository (`JEBOL0`)
- [ ] Select branch: `main`
- [ ] Confirm deployment

### 2. Add MySQL Database
- [ ] Click "+ Create"
- [ ] Select "MySQL"
- [ ] Wait for plugin to initialize
- [ ] Railway auto-generates DB credentials in environment

### 3. Set Environment Variables
In Railway dashboard, set these variables:

```
APP_KEY              = base64:YOUR_VALUE_FROM_ABOVE
APP_ENV              = production
APP_DEBUG            = false
APP_URL              = https://your-domain.railway.app
FRONTEND_URL         = https://your-mobile-app-url.com
LOG_LEVEL            = warning
CACHE_STORE          = database
QUEUE_CONNECTION     = database
SESSION_ENCRYPT      = true
```

**Variables containing database credentials** (auto-set by MySQL plugin):
- `DB_HOST` ✓
- `DB_PORT` ✓
- `DB_DATABASE` ✓
- `DB_USERNAME` ✓
- `DB_PASSWORD` ✓

Do NOT manually enter DB credentials; Railway manages these automatically.

---

## Post-Deployment Verification

### 1. Check Deployment Status
```bash
railway logs --tail
# Look for: "Application started successfully" or similar
```

### 2. Test API Health
```bash
curl https://your-domain.railway.app/api/health
# Expected: {"status":"ok"}
```

### 3. Test Authentication
```bash
curl -X POST https://your-domain.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "your_password",
    "device_name": "test"
  }'
# Expected: {"access_token":"...","refresh_token":"..."}
```

### 4. Check Database Status
```bash
railway run "php artisan migrate:status"
# All migrations should show as "yes" (completed)
```

### 5. Monitor Performance
- [ ] Visit Railway dashboard
- [ ] Check CPU usage (should be <50% idle)
- [ ] Check memory usage (should be <200MB)
- [ ] Check network I/O

---

## Common Issues & Fixes

### Issue: "502 Bad Gateway"

**Cause 1: APP_KEY Missing**
```bash
# Fix: Set APP_KEY variable
railway variables set APP_KEY="base64:your_key_here"
railway redeploy
```

**Cause 2: Database Connection Failed**
```bash
# Fix: Verify MySQL plugin is connected
railway variables get | grep DB_
# Should show DB_HOST, DB_POST, etc.

# If empty, add MySQL plugin via dashboard again
```

**Cause 3: Laravel Cache Corrupted**
```bash
railway run "php artisan cache:clear"
railway run "php artisan config:cache"
railway redeploy
```

### Issue: "500 Internal Server Error"
```bash
# Check error logs
railway logs -e ERROR

# Clear cache and config
railway run "php artisan cache:clear"
railway run "php artisan config:cache"

# Force redeploy
railway redeploy
```

### Issue: "CORS errors" in mobile app
```bash
# Verify FRONTEND_URL in Railway variables
railway variables get FRONTEND_URL

# Must match EXACT mobile app URL
# Update if needed:
railway variables set FRONTEND_URL="https://exact-url.com"
railway redeploy
```

### Issue: Migrations not running
```bash
# Check if release process worked
railway logs | grep migrate

# Manually run if needed
railway run "php artisan migrate --force"

# Check status
railway run "php artisan migrate:status"
```

---

## Security Verification

After deployment, verify these security settings:

- [ ] HTTPS enabled (auto-enabled by Railway, verify with browser)
- [ ] APP_DEBUG=false (prevents stack traces)
- [ ] SESSION_SECURE_COOKIE=true (cookies only over HTTPS)
- [ ] SESSION_HTTP_ONLY=true (prevents JS access to cookies)
- [ ] FRONTEND_URL restricted (not wildcard)
- [ ] Database backups enabled (Railway auto-backs up daily)

---

## Custom Domain (Optional)

If using custom domain (e.g., `api.jebol.go.id`):

1. **In Railway Dashboard**:
   - Project → Settings
   - Custom Domain
   - Enter: `api.jebol.go.id`

2. **At Your Domain Registrar**:
   - Add CNAME record:
     - Name: `api`
     - Value: `<your-railway-domain>`
   - Wait for DNS propagation (5-10 minutes)

3. **Verify**:
   ```bash
   nslookup api.jebol.go.id
   curl https://api.jebol.go.id/api/health
   ```

---

## Rollback Procedure

If something breaks in production:

### Option 1: Redeploy Previous Commit
```bash
# Find last working commit
git log --oneline | head -5

# Checkout and push
git checkout <commit_hash>
git push origin main --force-with-lease

# Railway auto-redeploys
```

### Option 2: Disable Service Temporarily
```bash
# In Railway dashboard:
# Project → Settings → Delete deployment
# This takes service offline immediately
```

---

## Monitoring & Alerts

### Enable Email Notifications
- [ ] Railway account → Settings → Notifications
- [ ] Enable email alerts for deployment failures

### External Monitoring
Consider adding:
- **Uptime Monitoring**: UptimeRobot (free)
- **Error Tracking**: Sentry (add to .env)
- **Performance**: New Relic (optional)

---

## Support & Troubleshooting

### Useful Commands
```bash
railway logs                    # View all logs
railway logs -e ERROR         # View only errors
railway variables             # List all env variables
railway run "command"         # Run artisan command
railway shell                 # SSH into container
railway redeploy              # Force redeploy
```

### Important Links
- Railway Docs: https://docs.railway.app
- Laravel on Railway: https://docs.railway.app/guides/laravel
- Project Dashboard: https://railway.app (login required)

---

## Deployment Complete ✅

Your JEBOL Backend is now deployed on Railway!

Next steps:
1. Configure mobile app to use `APP_URL` from Railway
2. Test with real data
3. Set up monitoring and alerts
4. Document access credentials for team

Questions? See [RAILWAY_DEPLOYMENT.md](RAILWAY_DEPLOYMENT.md)
