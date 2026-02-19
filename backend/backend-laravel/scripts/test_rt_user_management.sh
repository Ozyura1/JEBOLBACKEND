#!/bin/bash

# Quick test script for RT User Management endpoints
# Make sure you have a SUPER_ADMIN token first!

BASE_URL="http://localhost:8000/api"
SUPER_ADMIN_TOKEN="your_super_admin_token_here"

echo "=== Testing RT User Management Endpoints ==="
echo ""

# 1. Create RT User
echo "1. Creating RT user..."
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/admin/users/rt/create" \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "rt_kelurahan_test_'$(date +%s)'",
    "password": "TestPass123",
    "password_confirmation": "TestPass123",
    "notes": "Test RT account for Kelurahan ABC"
  }')

echo $CREATE_RESPONSE | jq '.'
RT_USER_ID=$(echo $CREATE_RESPONSE | jq -r '.data.id')
echo "Created RT User ID: $RT_USER_ID"
echo ""

# 2. List RT Users
echo "2. Listing RT users..."
curl -s -X GET "$BASE_URL/admin/users/rt?page=1&per_page=10" \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN" \
  -H "Content-Type: application/json" | jq '.'
echo ""

# 3. Get Single RT User
echo "3. Getting single RT user (ID: $RT_USER_ID)..."
curl -s -X GET "$BASE_URL/admin/users/rt/$RT_USER_ID" \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN" \
  -H "Content-Type: application/json" | jq '.'
echo ""

# 4. Update RT User
echo "4. Updating RT user..."
curl -s -X PATCH "$BASE_URL/admin/users/rt/$RT_USER_ID" \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "is_active": false,
    "notes": "Updated: Disabled for testing"
  }' | jq '.'
echo ""

# 5. Reset Password
echo "5. Resetting RT user password..."
curl -s -X POST "$BASE_URL/admin/users/rt/$RT_USER_ID/reset-password" \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "password": "NewTestPass456",
    "password_confirmation": "NewTestPass456"
  }' | jq '.'
echo ""

# 6. Delete RT User
echo "6. Deleting RT user..."
curl -s -X DELETE "$BASE_URL/admin/users/rt/$RT_USER_ID" \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN" \
  -H "Content-Type: application/json" | jq '.'
echo ""

echo "=== Test Complete ==="
