# All Gujarat Vankar Samaj Matrimony & Community Platform
## Complete Technical & Operational Documentation (Up-to-Date)

---

## 1. Executive Summary & Vision

**All Gujarat Vankar Samaj** ([`allgujaratvankarsamaj.com`](https://allgujaratvankarsamaj.com)) is a premier, community-driven digital matrimonial and socio-cultural portal developed specifically for the **Vankar Samaj** across Gujarat and the global diaspora.

The platform unites modern matchmaking technology with deep cultural community roots, offering:
- **Verified Matrimonial Matchmaking**: 100% genuine matrimonial candidate profiles backed by government ID verification and AI-assisted cross-checks.
- **Socio-Cultural Directory**: Interactive directories for Parganas, Talukas, Villages, Lineages, and Family trees.
- **Community Pride & Recognition**: Dedicated portals honoring **Samaj Ratna** awardees, **Samaj Super Stars**, **Pavan Prernadata** (inspiring elders), and verified **Government Employees** (civil servants, police officers, educators, bank managers).
- **Social Services & Upliftment**: Samaj Sevaks directory, education & career coaching resources, community business advertisements, and matrimonial success stories.
- **Privacy & Security First**: Strict multi-tiered privacy controls (hiding phone, email, and address based on gender or candidate choice), encrypted passwords, and secure JWT session handling.

---

## 2. High-Level System Architecture

The platform uses a decoupled, high-performance architecture engineered for scalability, fast page loads, and native mobile/web interoperability:

```mermaid
flowchart TD
    subgraph ClientLayer ["Client Application (Flutter Web & Mobile)"]
        UI["Flutter 3.47 / Dart 3.13 Multiplatform Web & App"]
        Router["GoRouter (Deep Linking & Guards)"]
        StateMgr["Riverpod 2.6 (State & Dependency Management)"]
        DioClient["Dio HTTP Client (Auth Interceptor & Base64/Multipart)"]
        AIVerifier["Client AI Verifier (Gemini Direct Fallback)"]
    end

    subgraph GatewayLayer ["Reverse Proxy & Hostinger Web Gateway"]
        Apache["Apache Web Server (.htaccess)"]
        Proxy["api_proxy.php (Self-Healing Unix Socket Gateway)"]
    end

    subgraph BackendLayer ["Next-Nest Backend (NestJS 10 / Node.js)"]
        NestApp["NestJS Modular Backend (Port 3000 / Unix Domain Socket)"]
        AuthMod["Auth & OTP Module (40s Cooldown)"]
        ProfileMod["Matrimonial Profile Module"]
        VerifMod["Verifications Module + Gemini 1.5 Vision AI"]
        CommunityMod["Community & Master Data Module"]
        StorageMod["Storage Service (Public /uploads & Private /private_uploads)"]
        PrismaORM["Prisma ORM 5.22"]
    end

    subgraph DataLayer ["Database & External Services"]
        MySQL["MySQL / PostgreSQL Database"]
        GeminiAPI["Google Gemini 1.5 Flash Vision AI (Document OCR)"]
        SMSService["Fast2SMS / SMTP Email OTP Gateway"]
    end

    UI --> Router --> StateMgr --> DioClient
    DioClient -->|HTTPS API Requests| Apache --> Proxy --> NestApp
    NestApp --> AuthMod & ProfileMod & VerifMod & CommunityMod & StorageMod
    VerifMod -->|Multimodal Image Analysis| GeminiAPI
    AuthMod -->|SMS / Email Dispatch| SMSService
    NestApp --> PrismaORM --> MySQL
    AIVerifier -.->|Direct Fallback if Gateway Offline| GeminiAPI
```

---

## 3. Technology Stack

| Layer | Technology | Version | Purpose |
| :--- | :--- | :--- | :--- |
| **Frontend Framework** | **Flutter Web & Mobile** | `3.47.5-stable` / Dart `3.13.2` | Single codebase compiled for Web, Android, and iOS. |
| **Client State Management** | **Flutter Riverpod** | `^2.6.1` | Reactive, testable state management and provider scoping. |
| **Routing & Navigation** | **GoRouter** | `^14.8.1` | Declarative routing, browser URL sync, auth redirect guards. |
| **HTTP Client** | **Dio** | `^5.7.0` | Token interceptor, file upload streaming, timeout resiliency. |
| **Backend Framework** | **NestJS** | `^10.4.15` | Enterprise TypeScript framework with modular architecture. |
| **ORM / Data Access** | **Prisma ORM** | `^5.22.0` | Type-safe database queries, schema migrations, and relations. |
| **Database** | **MySQL / PostgreSQL** | `8.0+ / 15+` | Relational database for matrimonial and community records. |
| **AI Vision Engine** | **Google Gemini 1.5 Flash** | `@google/generative-ai ^0.24.1` | Real-time identity document validation (Name & DOB matching). |
| **Security & Cryptography** | **Passport-JWT / Bcrypt** | `^0.7.0 / ^6.0.0` | Bearer token authentication, password hashing, RBAC guards. |
| **Web Server & Hosting** | **Hostinger Linux Cloud** | Apache + PHP 8.3 | Reverse proxy (`api_proxy.php`), Unix domain socket communication. |

---

## 4. Complete Feature Breakdown

### 4.1 Authentication & Security (`/login`, `/register`)
- **Dual-Identifier Login**: Users can log in using either their registered **Mobile Number (10 digits)** or **Email Address** with their password.
- **OTP-Powered Registration**:
  - Requires mobile number or email verification during signup.
  - **40-Second Cooldown Timer**: When an OTP is dispatched, a real-time 40-second countdown is displayed (`Resend in 40s`).
  - **Auto Guidance on Expiry**: If the timer reaches 0 and the code has not arrived, an amber helper prompt invites the candidate to resend (`OTP કોડ નથી મળ્યો? ફરી કોડ મોકલવા માટે ઉપર "ફરી કોડ મોકલો" બટન દબાવો`).
  - Clean green confirmation banner on new OTP dispatch.
- **Session Preservation**: JWT tokens stored securely via `FlutterSecureStorage` with automated `/auth/me` refresh so user phone, verified status, and name are never lost across app restarts.
- **Role-Based Access Control (RBAC)**: Supports roles `SUPER_ADMIN`, `ADMIN`, `VERIFICATION_ADMIN`, `COMMUNITY_ADMIN`, and `MEMBER`.

---

### 4.2 Matrimonial Profiles (`/profile`, `/profile/create`, `/profile/edit`)

#### Core Profile Fields
- **Personal Details**: First Name (પ્રથમ નામ), Last Name (અટક/સરનેમ), Date of Birth, Gender, Marital Status (Never Married, Divorced, Widowed, Awaiting Divorce), Blood Group, Mother Tongue.
- **Community Lineage**: Vankar sub-caste, Pargana selection, Native Village (મૂળ ગામ), Mother's Village (મોસાળ/મામાનું ગામ), Taluka, District, State, Country.
- **Education & Career**:
  - Highest qualification: Doctor (MBBS/MD), Engineer (BE/BTech/ME), CA/CS, MBA, MCA/MSc, Graduate, Post-Graduate, or custom degree.
  - Employment Type: Government Central, Government State, Semi-Government, Corporate/Private, Business/Self-Employed, Abroad/NRI.
  - Department (for govt employees), Designation, Company Name, Annual Income bracket.
- **Family Background**: Father's Name & Occupation, Mother's Name & Occupation, Siblings details, Guardian/Alt contact.
- **Physical Attributes**: Height, Weight, Body Type, Physical Disability status (PwBD Category), Lifestyle habits.
- **About Me**: Free-form biodata biography in Gujarati/English.

#### Photo Gallery
- **Primary Avatar**: High-resolution profile photo.
- **Gallery**: 2 to 5 additional lifestyle/family photos with on-device thumbnail preview, reordering, and individual removal.
- **File Validation**: Strict 5 MB client and server enforcement, automatic base64/multipart fallback.

#### Privacy Control Matrix
Candidates can independently configure privacy for:
- **Mobile Number**: `બધા માટે (Everyone)`, `પરિવારજનો (Members only)`, or `માત્ર મને (Only me)`. Default is automated based on female safety protocols.
- **Email Address**: `બધા માટે`, `પરિવારજનો`, `માત્ર મને`.
- **Address Details**: `પરિવારજનો`, `બધા માટે`, `માત્ર મને`.

---

### 4.3 AI-Powered Government ID Document Verification

To guarantee that matrimonial profiles are 100% authentic and prevent fake accounts or identity theft, the system features a dedicated verification pipeline:

```mermaid
sequenceDiagram
    autonumber
    actor Candidate
    participant Flutter as Flutter App (Create/Edit Profile)
    participant Backend as NestJS Backend (Verifications)
    participant Gemini as Google Gemini 1.5 Flash Vision AI

    Candidate->>Flutter: Fills First Name, Last Name & Date of Birth
    Candidate->>Flutter: Selects ID Type (Aadhaar / PAN / Voter ID / DL)
    Candidate->>Flutter: Taps Front Side Photo Upload
    Flutter->>Flutter: Checks if Name & DOB are entered (Shows reminder if missing)
    Flutter->>Flutter: Opens Camera / Gallery, selects image
    Flutter->>Flutter: Launches AI Scanning Dialog ("AI ઓળખપત્ર ચકાસણી...")
    Flutter->>Backend: POST /verifications/ai-verify (Image + Expected Name + DOB)
    Backend->>Gemini: Multimodal Vision Prompt (Extract Name & DOB + Validate ID)
    Gemini-->>Backend: JSON: { isValidDocument, extractedName, extractedDob, nameMatched, dobMatched }
    
    alt Name & DOB Match
        Backend-->>Flutter: { success: true, verified: true, extractedDetails }
        Flutter->>Flutter: Attaches Photo, Marks `_isIdFrontAiVerified = true`
        Flutter->>Flutter: Renders Green "✓ AI Verified" Badge + Name/DOB Chip
    else Name or DOB Mismatched (e.g. Someone else's ID)
        Backend-->>Flutter: { success: false, verified: false, reason: "NAME_MISMATCH" }
        Flutter->>Flutter: Rejects Photo (Does NOT attach, keeps slot empty)
        Flutter->>Candidate: Displays Bilingual Rejection Dialog with exact mismatch details
    end
```

#### Key Capabilities of the AI Verification Engine:
1. **Multilingual Indian Name Resolution**:
   - Compares English and Gujarati/Devanagari text printed on government ID cards.
   - Handles patronymic middle names (e.g. `Ramesh Arvindbhai Vankar` matches profile `Ramesh Vankar`).
   - Normalizes honorific suffixes (`bhai`, `kumar`, `ben`, `devi`, `lal`, `prasad`).
   - Tolerates minor phonetic transliteration differences with token containment and string distance algorithms.
2. **Flexible DOB & Birth Year Matching**:
   - Matches standard date formats: `DD/MM/YYYY`, `DD-MM-YYYY`, `YYYY-MM-DD`.
   - Recognizes Aadhaar cards that only display `Year of Birth: YYYY`.
3. **Strict Zero-False-Positive Visual State**:
   - The card banner and header **never** turn green based solely on file selection.
   - The green light and `✓ ઓળખપત્ર AI દ્વારા ચકાસાયેલ છે (ID Proof AI Verified)` status **strictly require `isBothAiVerified == true`**.
   - If an unverified or mismatched ID is selected, the UI shows an amber warning: `⚠️ ઓળખપત્ર AI દ્વારા ચકાસવું જરૂરી છે (AI Verification Required)`.

---

### 4.4 Search, Discovery & Matchmaking

- **Quick Search (`/search`)**: Filter by Age range (e.g., 21 to 35), Minimum Height, Marital Status, Education, and District.
- **Advanced Search (`/advanced-search`)**: Granular filtering by:
  - Sub-caste / Gotra
  - Pargana & Specific Native Village
  - Employment type (Govt Central / State / Corporate / Business)
  - Annual Income bracket
  - Diet & Lifestyle preferences
- **Search Results (`/search-results`)**: High-performance paginated card grid with profile picture, age, education, city, and verified badges.
- **Candidate Profile Details (`/candidate-profile-details`)**:
  - Full-screen picture viewer with zoom.
  - Complete biodata, horoscope/kundali details, family info, and pargana lineage.
  - Privacy-shielded contact cards (displays phone/email only if permissions allow).
  - One-tap "Express Interest" (રસ દાખવો) and "Shortlist" (પસંદગી).
- **Match Recommendations (`/match`)**: Intelligent automated matching algorithm based on mutual age criteria, education compatibility, and pargana preferences.
- **Liked / Shortlisted Profiles (`/liked-profiles`)**: Bookmark candidates to review with family later.

---

### 4.5 Community & Socio-Cultural Portals

| Route | Feature Name | Description |
| :--- | :--- | :--- |
| `/pargana-overview` | **Pargana & Village Directory** | Complete interactive geographical directory of all Vankar Samaj parganas, associated talukas, and registered villages with leader contacts. |
| `/government-employees` | **Government Employees Directory** | Official directory of community members serving in Central/State Government, Police, Railways, Judiciary, Banking, and Education with designation and verification badges. |
| `/samaj-super-stars` | **Samaj Super Stars** | Hall of fame celebrating prominent artists, scholars, sports icons, entrepreneurs, and high achievers of the Samaj. |
| `/samaj-ratna` | **Samaj Ratna Awards** | Lifetime community honor roll honoring outstanding philanthropists and leaders. |
| `/pavan-prernadata` | **Pavan Prernadata** | Biographical archive of senior mentors, spiritual leaders, and historic inspirations. |
| `/samaj-services` | **Samaj Services & Sevaks** | Emergency community contacts, blood donor network, legal assistance, and funeral aid volunteers. |
| `/education` | **Education & Career Cell** | Competitive exam guidance (GPSC, UPSC, Banking), scholarships, student hostel directories, and career counseling. |
| `/family-details` | **Family & Lineage Archive** | Digital directory capturing native village roots, lineage, and family connections. |
| `/success-stories` | **Matrimonial Success Stories** | Testimonials and photos of couples successfully united through the platform. |
| `/birthdays` | **Daily Community Birthdays** | Automated daily birthday announcements and blessing board. |
| `/statistics` | **Samaj Demographic Analytics** | Interactive graphs displaying education breakdown, district demographics, gender ratios, and employment trends. |

---

### 4.6 Real-Time Messaging & Chat (`/conversations`, `/chat/:conversationId`)

- **Secure 1-to-1 Chat**: Direct messaging between candidates whose profiles have accepted express interests.
- **Media Attachments**: Send photos, biodata PDFs, and voice messages within chat.
- **Read Receipts & Timestamps**: Delivered, read, and active status tracking.
- **Moderation Guardrails**: Block user, report inappropriate conduct (`/reports`), and automated word filters.

---

### 4.7 Administration Panel & Moderation

- **Executive Analytics Dashboard**: Real-time KPI counters (Total Profiles, Pending Verifications, Active Members, Daily Registrations).
- **Verification Management Queue (`/admin/verifications`)**:
  - Side-by-side inspection of Front and Back ID photos.
  - View AI extracted data vs profile data with confidence score.
  - One-click "Approve & Mark Verified" or "Reject with Custom Reason" (sends push/SMS notification to user).
- **OTP Telemetry & Analytics**:
  - Visual charts showing OTP delivery success vs failure rates.
  - Average delivery time, resend counts, and carrier breakdown.
- **Master Data Manager**: Add, edit, or disable Districts, Talukas, Parganas, and Villages without code deployment.
- **User Moderation**: Suspend spam accounts, review user reports, and toggle featured profiles.

---

## 5. Database Schema & Core Data Models (Prisma)

The relational backend is modeled around the following core Prisma models:

```prisma
// Core User Authentication
model User {
  id               String              @id @default(uuid())
  email            String?             @unique
  phone            String?             @unique
  passwordHash     String              @map("password_hash")
  role             Role                @default(MEMBER)
  isPhoneVerified  Boolean             @default(false)
  isEmailVerified  Boolean             @default(false)
  isVerified       Boolean             @default(false)
  matrimonialProfile MatrimonialProfile?
  ...
}

// Comprehensive Matrimonial Candidate
model MatrimonialProfile {
  id                   String        @id @default(uuid())
  userId               String        @unique @map("user_id")
  user                 User          @relation(fields: [userId], references: [id])
  firstName            String        @map("first_name")
  lastName             String        @map("last_name")
  dateOfBirth          DateTime      @map("date_of_birth")
  gender               Gender
  maritalStatus        MaritalStatus @map("marital_status")
  religion             String?
  caste                String?
  nativePlace          String?       @map("native_place")
  education            String?
  occupation           String?
  annualIncome         String?       @map("annual_income")
  fatherName           String?       @map("father_name")
  motherName           String?       @map("mother_name")
  mamasVillage         String?       @map("mamas_village")
  photoUrl             String?       @map("photo_url")
  photos               String?       @db.Text
  idProofType          String?       @map("id_proof_type")
  idProofNumber        String?       @map("id_proof_number")
  idProofFrontUrl      String?       @map("id_proof_front_url")
  idProofBackUrl       String?       @map("id_proof_back_url")
  privacySettings      String?       @db.Text
  status               ProfileStatus @default(PENDING)
  isVerified           Boolean       @default(false)
  showInMatrimony      Boolean       @default(true)
  ...
}

// Verification Queue & Auditing
model VerificationRequest {
  id              String             @id @default(uuid())
  profileId       String             @map("profile_id")
  profile         MatrimonialProfile @relation(fields: [profileId], references: [id])
  documentType    String             @map("document_type")
  documentUrl     String             @map("document_url")
  documentBackUrl String?            @map("document_back_url")
  status          VerificationStatus @default(PENDING)
  rejectionReason String?            @map("rejection_reason")
  createdAt       DateTime           @default(now())
}
```

---

## 6. Hosting, Deployment & Infrastructure

### 6.1 Production Infrastructure Overview
- **Domain**: `https://allgujaratvankarsamaj.com`
- **Hosting Provider**: Hostinger Cloud / VPS
- **Server Architecture**:
  - Apache Web Server handles incoming HTTPS requests, SSL termination, and static asset delivery.
  - `api_proxy.php` acts as a high-speed, self-healing reverse proxy forwarding `/api/v1/*` requests to the NestJS application via a Unix Domain Socket (`backend.sock`) or TCP `127.0.0.1:3000`.
  - Automated watchdog (`keep_backend_alive.sh`) monitors socket health and auto-restarts the backend within milliseconds if an outage occurs.

### 6.2 Storage & Media Management
- **Public Uploads** (`/uploads`): For profile avatars, gallery photos, and community posters. Enforces strict image MIME types (`.jpg`, `.png`, `.webp`) and a 5 MB maximum size.
- **Private Uploads** (`/private_uploads`): For sensitive government identity cards (Aadhaar, PAN, DL). Stored outside the public web root with restricted permissions (`0600`), streamable only by authenticated administrators and the candidate themselves via `/verifications/my-document/:filename`.

---

## 7. Web Build & Release Procedures

### How to Build & Deploy Updates:

1. **Compile Flutter Web Release**:
   ```bash
   cd application
   flutter build web --release
   ```
   *Output generated to `application/build/web` with WebAssembly optimization, tree-shaken icons, and gzip/brotli pre-compression.*

2. **Compile NestJS Backend**:
   ```bash
   cd next-nest/backend
   npm run build
   ```
   *Outputs optimized TypeScript binaries to `next-nest/backend/dist/`.*

3. **Database Migration**:
   ```bash
   npx prisma migrate deploy
   ```

4. **Environment Variables Required**:
   ```env
   # Backend .env
   PORT=3000
   DATABASE_URL="mysql://user:pass@localhost:3306/vankar_matrimony"
   JWT_SECRET="your-jwt-secret"
   JWT_EXPIRES_IN="7d"
   GEMINI_API_KEY="AIzaSy...your-free-gemini-key"
   ```

---

## 8. Summary of Recent Improvements (Latest Release)

1. **OTP Verification & 40-Second Cooldown**:
   - Replaced 60s cooldown with **40-second resend cooldown timer**.
   - Added automatic expired-timer guidance box in Gujarati and English.
   - Synchronized verified phone and email flags across `CreateProfileScreen`, `EditProfileScreen`, and the backend.
2. **AI Document Verification System**:
   - Powered by **Google Gemini 1.5 Flash Vision AI**.
   - Automatically cross-verifies candidate Name (with Indian suffix and patronymic resolution) and Date of Birth against uploaded ID cards.
   - **Zero False Positives**: Fixed the legacy "green light" bug so that the card and status banner only turn green when real AI verification succeeds. Mismatched or fake documents are rejected and blocked from attachment.
3. **Flutter Web Release**:
   - Fully compiled and updated in `application/build/web` for immediate live deployment.

