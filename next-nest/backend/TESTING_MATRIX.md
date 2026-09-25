# Testing Matrix

This document outlines the testing strategy for the All Gujarat Vankar Samaj Matrimony platform. Testing is split across different domains to ensure full coverage of business logic, security constraints, and data integrity.

## 1. End-to-End (E2E) Flow Verification

**Script**: `e2e_flow_verification.js`
**Purpose**: Proves that the core user journeys are functionally correct and that data flows seamlessly from the client layer through the backend to the MySQL 8.0 database.
**Coverage**:
- User Registration (`POST /auth/register`)
- Authentication (`POST /auth/login`)
- Profile Completion & DTO Validation (`POST /profiles`)
- Aadhaar Document Verification (`POST /verifications/submit`)
- Admin Panel Authentication
- Admin Approval Pipeline (`PATCH /admin/verifications/:id/verify`)
- Universal Listing & Search filtering (`GET /profiles?gender=FEMALE`)
- Match Interest Exchange (`POST /interests/send`)
- Match Interest Acceptance (`PATCH /interests/:id/accept`)

**Execution**: `node e2e_flow_verification.js`

---

## 2. Security & Penetration Testing

**Script**: `security_verification.js`
**Purpose**: Proves that the API boundaries strictly enforce authentication, authorization (RBAC), and prevent horizontal privilege escalation.
**Coverage**:
- **Authentication**: Verifies JWT requirements on protected routes (`GET /auth/me`).
- **Authorization (RBAC)**: Verifies standard Users cannot access Admin routes (`GET /admin/verifications`).
- **Logic Constraints**: Verifies a user cannot send a match interest to themselves.
- **Ownership (BOLA/IDOR)**: Verifies that User A cannot modify or decline an interest belonging to User B.
- **Parameter Tampering**: Verifies that the API explicitly drops malicious injection attempts targeting core database fields (e.g., bypassing `isVerified` via `PATCH /profiles/me`) by relying on `class-validator` `whitelist` properties.

**Execution**: `node security_verification.js`

---

## 3. Integration & Audit Logging Tests

**Script**: `audit_logging_test.js`
**Purpose**: Proves that sensitive administrative actions correctly persist an audit trail with critical contextual metadata.
**Coverage**:
- Simulates an Admin performing a high-risk operation (`UPDATE_USER_STATUS`).
- Executes a raw database query to assert that an `AdminAuditLog` is created.
- Validates the presence of `Action`, `Entity`, `Entity ID`, `Before State`, `After State`, `Timestamp`, and `IP Address`.

**Execution**: `node audit_logging_test.js`

---

## Execution Guidelines
Before running the testing matrix, ensure the following systems are active:
1. **MySQL 8.0 Database**: Running on port `3306`.
2. **NestJS Backend**: Running via `npm run start:dev` (Listening on port `3000`).

To run the entire suite sequentially:
```bash
node e2e_flow_verification.js
node security_verification.js
node audit_logging_test.js
```
