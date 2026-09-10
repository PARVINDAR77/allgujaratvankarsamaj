# API Reference

This document maintains the API contract for the NestJS backend.

## Base URL
- Development: `http://localhost:3000/api/v1`
- Production: TBD

## Standard Response Format
**Success:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

**Error:**
```json
{
  "success": false,
  "message": "Error message",
  "errors": [ ... ]
}
```

*(API endpoints will be documented here as they are implemented).*
