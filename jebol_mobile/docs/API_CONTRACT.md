# JEBOL Mobile - API Contract Lock

## Version: 1.0.0
## Last Updated: 2025-01-08

---

## Overview

This document defines the locked API contract between the JEBOL mobile app and Laravel backend.
All endpoints listed here are considered stable and should not change without version negotiation.

---

## Authentication Endpoints

### POST /api/auth/login
**Request:**
```json
{
  "username": "string",
  "password": "string",
  "device_name": "string"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "access_token": "string",
    "refresh_token": "string",
    "expires_in": 3600,
    "user": {
      "id": "uuid",
      "username": "string",
      "nama": "string",
      "role": "string"
    }
  }
}
```

### POST /api/auth/refresh
**Headers:** `Authorization: Bearer {refresh_token}`

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "string"
  }
}
```

### POST /api/auth/logout
**Headers:** `Authorization: Bearer {access_token}`

**Response:**
```json
{
  "success": true,
  "message": "Logout berhasil"
}
```

### GET /api/auth/me
**Headers:** `Authorization: Bearer {access_token}`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "username": "string",
    "nama": "string",
    "email": "string",
    "role": "string"
  }
}
```

---

## Registration Events

### POST /api/perkawinan
**Description:** Submit marriage registration

**Headers:** `Authorization: Bearer {access_token}`

**Request (multipart/form-data):**
```
nama_suami: string
nik_suami: string (16 digits)
tempat_lahir_suami: string
tanggal_lahir_suami: date (YYYY-MM-DD)
nama_istri: string
nik_istri: string (16 digits)
tempat_lahir_istri: string
tanggal_lahir_istri: date (YYYY-MM-DD)
tanggal_perkawinan: date (YYYY-MM-DD)
tempat_perkawinan: string
dokumen_ktp_suami: file (jpg,png,pdf max 2MB)
dokumen_ktp_istri: file (jpg,png,pdf max 2MB)
dokumen_akta_nikah: file (jpg,png,pdf max 2MB)
```

**Response:**
```json
{
  "success": true,
  "message": "Permohonan perkawinan berhasil diajukan",
  "data": {
    "id": "uuid",
    "nomor_registrasi": "string",
    "status": "PENDING"
  }
}
```

### GET /api/perkawinan
**Description:** List user's marriage registrations

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "nomor_registrasi": "string",
      "status": "PENDING|VERIFIED|APPROVED|REJECTED",
      "created_at": "datetime"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "total": 1
  }
}
```

### GET /api/perkawinan/{id}
**Description:** Get marriage registration detail

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "nomor_registrasi": "string",
    "nama_suami": "string",
    "nik_suami": "string",
    "nama_istri": "string",
    "nik_istri": "string",
    "tanggal_perkawinan": "date",
    "status": "string",
    "catatan_admin": "string|null",
    "documents": [
      {
        "id": "uuid",
        "type": "string",
        "url": "string"
      }
    ],
    "created_at": "datetime",
    "updated_at": "datetime"
  }
}
```

---

## Admin Endpoints

### GET /api/admin/perkawinan
**Query Parameters:**
- status: PENDING|VERIFIED|APPROVED|REJECTED
- page: integer
- per_page: integer (default 10)

**Response:**
```json
{
  "success": true,
  "data": [...],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "total": 50
  }
}
```

### POST /api/admin/perkawinan/{id}/verify
**Request:**
```json
{
  "catatan_admin": "string (optional)"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Permohonan berhasil diverifikasi"
}
```

### POST /api/admin/perkawinan/{id}/approve
**Response:**
```json
{
  "success": true,
  "message": "Permohonan berhasil disetujui"
}
```

### POST /api/admin/perkawinan/{id}/reject
**Request:**
```json
{
  "alasan_penolakan": "string (required)"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Permohonan ditolak"
}
```

---

## Standard Error Responses

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Sesi Anda telah berakhir. Silakan login kembali."
}
```

### 422 Validation Error
```json
{
  "success": false,
  "message": "Data tidak valid",
  "errors": {
    "field_name": ["Error message"]
  }
}
```

### 500 Server Error
```json
{
  "success": false,
  "message": "Terjadi kesalahan pada server"
}
```

---

## Response Schema Contract

All API responses MUST follow this structure:
```json
{
  "success": "boolean",
  "message": "string",
  "data": "object|array|null",
  "meta": "object|null",
  "errors": "object|array|null"
}
```

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01-08 | Initial API lock for production release |
