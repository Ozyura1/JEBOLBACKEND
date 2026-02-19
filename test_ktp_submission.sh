#!/bin/bash

# Test KTP submission untuk Khusus Lansia
# Ganti TOKEN dengan token authentication dari login

TOKEN="your_bearer_token_here"
BASE_URL="http://localhost:8000"

echo "Testing KTP Submission - Khusus Lansia..."
curl -X POST "$BASE_URL/api/rt/ktp/submit" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nama=Test User&nomor_telp=08123456789&alamat_manual=Jl Test No 1&latitude=-6.2088&longitude=106.8456&kategori=khusus&kategori_khusus=lansia&minimal_usia=60&jumlah_pemohon=1" \
  -v

echo -e "\n\nTesting KTP Submission - Umum..."
curl -X POST "$BASE_URL/api/rt/ktp/submit" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nama=Test User&nomor_telp=08123456789&alamat_manual=Jl Test No 1&latitude=-6.2088&longitude=106.8456&kategori=umum&minimal_usia=16&jumlah_pemohon=15" \
  -v

echo -e "\n\nDone!"
