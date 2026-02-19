#!/bin/bash
# =====================================================
# Railway Deployment Helper Script
# Usage: ./deploy-railway.sh
# =====================================================

set -e

echo "🚀 JEBOL Backend - Railway Deployment Helper"
echo "=========================================="
echo ""

# Check if railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Install from: https://railway.app"
    exit 1
fi

# Get current project status
echo "📊 Current Railway Project Status:"
railway variables

echo ""
echo "=========================================="
echo "✅ Deployment Checklist:"
echo "=========================================="
echo ""

# Checklist items
checklist=(
    "APP_KEY is set (not empty)"
    "APP_ENV is set to 'production'"
    "APP_DEBUG is set to 'false'"
    "APP_URL is set to your domain"
    "FRONTEND_URL matches your mobile app URL"
    "DB_HOST/DB_PORT/DB_USERNAME/DB_PASSWORD are auto-populated by MySQL plugin"
    "All code is committed: git push origin main"
    "MySQL plugin is added to Railway project"
)

for i in "${!checklist[@]}"; do
    echo "[ ] $((i+1)). ${checklist[$i]}"
done

echo ""
echo "=========================================="
echo "🚀 Ready to deploy? Press Enter to continue..."
read

echo ""
echo "📝 Deploying from main branch..."
git push origin main

echo ""
echo "⏳ Railway is auto-deploying... Check logs in 30 seconds."
echo "   Command: railway logs --tail"
echo ""
echo "✅ Deployment started! Monitor progress at:"
echo "   https://railway.app (dashboard)"
echo ""
echo "After deployment, verify:"
echo "   curl https://\$APP_URL/api/health"
