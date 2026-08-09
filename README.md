# 🌱 Shiksha Saathi — शिक्षा साथी
### AI-Powered Teacher Assistant for Rural India

A production-grade, offline-first, bilingual (Hindi + English) full-stack app for government school teachers, students, and parents.

---

## 📁 Project Structure

```
shiksha_saathi/
├── backend/                    # Node.js + Express API
│   ├── src/
│   │   ├── app.js              # Express app setup
│   │   ├── server.js           # Entry point
│   │   ├── config/
│   │   │   └── database.js     # PostgreSQL pool
│   │   ├── cache/
│   │   │   └── redis.js        # Redis cache helpers + TTL
│   │   ├── database/
│   │   │   └── schema.sql      # Complete DB schema
│   │   ├── middleware/
│   │   │   ├── auth.middleware.js  # JWT + role guards
│   │   │   └── index.js        # Rate limiter, validator, logger
│   │   ├── modules/
│   │   │   ├── auth/           # Register, OTP, Login, Refresh, Forgot
│   │   │   ├── teacher/        # Dashboard, Lessons, Attendance, Worksheets
│   │   │   ├── student/        # Progress, Quizzes, Attendance history
│   │   │   ├── parent/         # Children, Progress, Notifications
│   │   │   └── ai/             # Lesson gen, Worksheet, Doubt solver, SMS
│   │   └── utils/
│   │       ├── jwt.js          # Token generation/verification
│   │       ├── logger.js       # Winston structured logging
│   │       └── response.js     # Consistent API response helpers
│   └── .env.example
│
└── frontend/                   # Flutter app (Clean Architecture)
    └── lib/
        ├── main.dart           # App entry point
        ├── core/
        │   ├── theme/          # Material 3 theme, colors, typography
        │   ├── constants/      # Strings (EN + HI), assets
        │   ├── network/        # Dio API client with interceptors
        │   └── router/         # GoRouter with auth guards
        ├── features/
        │   ├── auth/           # Onboarding, Login, Register, OTP, Forgot PW
        │   ├── teacher/        # Dashboard, Lesson Planner, Attendance, Worksheets
        │   ├── student/        # Dashboard, Progress, Study Buddy
        │   └── parent/         # Dashboard, Child Progress, AI Assistant
        └── shared/
            └── widgets/        # AppButton, AppCard, AiChatSheet, etc.
```

---

## 🚀 Backend Setup

### Prerequisites
- Node.js 18+
- PostgreSQL 14+
- Redis 7+

### Steps

```bash
cd backend

# 1. Install dependencies
npm install

# 2. Configure environment
cp .env.example .env
# Fill in: DB_*, REDIS_*, JWT_SECRET, OPENROUTER_API_KEY, TWILIO_*

# 3. Create database
createdb shiksha_saathi

# 4. Run schema
psql -d shiksha_saathi -f src/database/schema.sql

# 5. Create logs directory
mkdir -p logs

# 6. Start (development)
node src/server.js

# API runs at: http://localhost:5000
# Health check: http://localhost:5000/health
```

### API Endpoints

| Module | Method | Endpoint | Auth |
|--------|--------|----------|------|
| Auth | POST | `/api/v1/auth/register` | Public |
| Auth | POST | `/api/v1/auth/verify-otp` | Public |
| Auth | POST | `/api/v1/auth/login` | Public |
| Auth | POST | `/api/v1/auth/forgot-password` | Public |
| Auth | POST | `/api/v1/auth/refresh-token` | Public |
| Auth | POST | `/api/v1/auth/logout` | Bearer |
| Teacher | GET | `/api/v1/teacher/dashboard` | Teacher |
| Teacher | GET/POST | `/api/v1/teacher/lesson-plans` | Teacher |
| Teacher | GET/POST | `/api/v1/teacher/classes/:id/attendance` | Teacher |
| Teacher | GET/POST | `/api/v1/teacher/worksheets` | Teacher |
| Student | GET | `/api/v1/student/dashboard` | Student |
| Student | GET | `/api/v1/student/progress` | Student |
| Parent | GET | `/api/v1/parent/children` | Parent |
| Parent | GET | `/api/v1/parent/children/:id/progress` | Parent |
| AI | POST | `/api/v1/ai/lesson-plan` | Any |
| AI | POST | `/api/v1/ai/worksheet` | Any |
| AI | POST | `/api/v1/ai/doubt` | Any |
| AI | POST | `/api/v1/ai/parent-assistant` | Any |
| AI | POST | `/api/v1/ai/sms-draft` | Any |

---

## 📱 Flutter Setup

### Prerequisites
- Flutter 3.19+ (Dart 3.0+)
- Android Studio / VS Code
- Android SDK / Xcode

### Steps

```bash
cd frontend

# 1. Install dependencies
flutter pub get

# 2. Create assets directories
mkdir -p assets/{images,animations,icons,fonts}

# 3. Configure API URL
# In lib/core/network/api_client.dart:
# Change _baseUrl to your backend URL
# Android emulator: http://10.0.2.2:5000/api/v1
# Physical device: http://YOUR_LOCAL_IP:5000/api/v1

# 4. Run
flutter run

# Build APK
flutter build apk --release
```

### Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management (BLoC pattern) |
| `go_router` | Navigation with auth guards |
| `hive_flutter` | Offline-first local storage |
| `dio` | HTTP client with interceptors |
| `flutter_secure_storage` | Token storage |
| `flutter_animate` | Smooth animations |
| `google_fonts` | Inter typography |
| `fl_chart` | Progress charts |
| `flutter_tts` | Voice output (Hindi) |

---

## 🏗 Architecture

### Backend: Clean Architecture
```
Routes → Controller → Service → Repository → Database
                              ↕
                           Cache (Redis)
                              ↕
                           AI (OpenRouter/Claude)
```

### Frontend: Feature-first Clean Architecture
```
Presentation (BLoC, Screens, Widgets)
     ↕
Domain (Use Cases, Entities, Repositories)
     ↕
Data (Models, Remote/Local Data Sources)
```

---

## ⚡ Caching Strategy

| Data | TTL | Key Pattern |
|------|-----|-------------|
| User profile | 1 hour | `user:{id}` |
| Teacher dashboard | 1 min | `teacher:dashboard:{id}` |
| Class students | 5 min | `class:students:{classId}` |
| Today's attendance | 1 min | `attendance:{classId}:{date}` |
| AI lesson plans | 24 hr | `ai:lesson:{grade}:{subject}:{topic}:{lang}` |
| AI worksheets | 24 hr | `ai:worksheet:{...}` |

---

## 🌍 Language Support

| Phase | Languages | Status |
|-------|-----------|--------|
| 1 | Hindi, English | ✅ Ready |
| 2 | Punjabi, Marathi, Bengali, Tamil | 🔜 Add ARB file |
| 3 | All 22 scheduled languages | 📅 Year 2 |

---

## 🗓 4-Week Build Roadmap

| Week | Tasks |
|------|-------|
| 1 | Backend + DB schema + Auth APIs + Flutter scaffold + Onboarding/Login |
| 2 | AI lesson plan API + Flutter lesson planner screen + Attendance UI |
| 3 | Worksheet builder + Parent SMS + Student/Parent portals + AI chat |
| 4 | Pilot with HP schools + Teacher feedback + PDF export + DIKSHA bridge |

---

## 🔐 Security Features

- JWT access tokens (15min) + refresh tokens (7 days) — rotated on every refresh
- Bcrypt password hashing (12 rounds)
- Blacklisted tokens via Redis on logout
- Rate limiting: 100 req/15min global, 10 req/15min auth, 5 req/min AI
- Helmet.js security headers
- Input validation via express-validator on all endpoints
- Role-based access control (teacher / student / parent / admin)

---

## 📦 Environment Variables

```env
# Backend (.env)
NODE_ENV=development
PORT=5000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=shiksha_saathi
DB_USER=postgres
DB_PASSWORD=your_password
REDIS_HOST=localhost
REDIS_PORT=6379
JWT_SECRET=min_32_char_secret
JWT_REFRESH_SECRET=min_32_char_secret
OPENROUTER_API_KEY=sk-or-...
TWILIO_ACCOUNT_SID=AC...
TWILIO_AUTH_TOKEN=...
TWILIO_PHONE_NUMBER=+91...
```

---

## 🙏 Built by Sumit · NIT Hamirpur · 2025

Stack: **Flutter + BLoC · Node.js + Express · PostgreSQL + pgvector · Redis · Claude AI (OpenRouter) · AWS S3**
