# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

**Maize Watch** is an IoT agriculture monitoring system for corn farmers. Real hardware sensors (DHT11, YL-69, LDR, pH sensor) push data to ThingSpeak; the backend syncs it every 15 seconds, runs analytics, and serves both a React web dashboard and a Flutter mobile app.

## Services Overview

| Service | Location | Port | Purpose |
|---------|----------|------|---------|
| Backend API | `backend/` | 3001 | Express/TypeScript REST + Socket.IO |
| Analytics | `analytics_v2/` | 8000 | Python/Flask ML service |
| Web Admin | `frontend/web-src/web-admin/` | 5173 | React dashboard |
| Web Public | `frontend/web-src/web-public/` | 5174 | Public landing site |
| Mobile | `frontend/mobile/` | — | Flutter app |
| Nginx | `nginx/` | 10000 | Reverse proxy (production) |

## Setup Requirements

Copy `.env.example` to `.env` in `backend/` and fill in:

```
MONGO_URI            # MongoDB Atlas or local
MONGO_IOT_URI        # Secondary MongoDB for IoT readings (can be same as above)
REDIS_URL            # Optional; API works without it
JWT_SECRET / JWT_REFRESH_SECRET
THINGSPEAK_READ_API_KEY / THINGSPEAK_CHANNEL_ID
TWILIO_ACCOUNT_SID / TWILIO_AUTH_TOKEN / TWILIO_PHONE_NUMBER
EMAIL_HOST / EMAIL_USER / EMAIL_PASSWORD
FIREBASE_PROJECT_ID / FIREBASE_PRIVATE_KEY / FIREBASE_CLIENT_EMAIL
ANALYTICS_SERVICE_URL  # http://localhost:8000 locally
```

For mobile, the base URL is set in `frontend/mobile/lib/core/config/environment.dart` — change the `development` URL to your machine's LAN IP.

Local dependencies via Docker:
```bash
docker-compose -f docker/docker-compose.yml up -d   # starts MongoDB + Redis
```

## Development Commands

### Backend (Node.js/TypeScript)
```bash
cd backend
npm install
npm run dev          # ts-node-dev watch mode
npm run build        # compile to dist/
npm start            # run compiled server
npm test             # Jest test suite
npx jest src/tests/auth   # single test file
```

### Analytics (Python)
```bash
cd analytics_v2
pip install -r requirements.txt
python app.py        # Flask dev server on :8000
# Production:
gunicorn -w 2 -b 0.0.0.0:8000 app:app
```

### Web Frontend
```bash
cd frontend/web-src
npm install
cd web-admin && npm run dev    # admin dashboard
cd web-public && npm run dev   # public site
```

### Flutter Mobile
```bash
cd frontend/mobile
flutter pub get
flutter run                           # debug on connected device/emulator
flutter pub run build_runner build    # regenerate JSON serialization code
flutter pub run intl_utils:generate   # regenerate localization files
flutter test                          # unit tests
flutter build apk                     # Android release
flutter build ios                     # iOS release
```

### Full Stack (PM2 + Nginx)
```bash
bash scripts/start.sh    # starts backend + analytics via PM2, Nginx on :10000
```

## Architecture

### Data Flow
```
IoT Sensors → ThingSpeak → syncService (every 15s) → MongoDB (SensorReading)
                                                    → Socket.IO broadcast → clients
MongoDB → analyticsService → Python ML service → Prescriptions
```

### Backend Layer Structure
- **Routes** (`src/routes/`) declare endpoints and attach middleware
- **Controllers** (`src/controllers/`) handle HTTP request/response only
- **Services** (`src/services/`) hold all business logic — controllers call services, never touch models directly
- **Models** (`src/models/`) are Mongoose schemas with no business logic

### Key Services
- `syncService.ts` — fetches ThingSpeak, maps field1-5 to temperature/humidity/soil moisture/light/pH, stores `SensorReading`, invalidates Redis cache
- `analyticsService.ts` — aggregation pipelines, trend/correlation analysis; calls Python service for ML predictions
- `cacheService.ts` — Redis wrapper with graceful fallback; API is fully functional without Redis
- `authService.ts` — JWT (access + refresh), bcrypt, TOTP 2FA, SMS reset via Twilio

### MongoDB Collections
- `users`, `farms`, `fields`, `sensors`, `sensorreadings` (main time-series), `iotreadingreadings` (IoT secondary DB), `prototypes` (ThingSpeak channel configs), `prescriptions`

### Mobile Architecture (Flutter — Clean Architecture)
Each feature under `lib/features/` follows:
```
feature/
  data/         datasources (remote/local), models, repository impl
  domain/       entities, repository interfaces, use cases
  presentation/ BLoC, screens, widgets
```
BLoCs: `AuthenticationBloc`, `FarmBloc`, `MonitoringBloc`, `AnalyticsBloc`, `PrescriptionBloc`, `SettingsBloc`

DI is wired in `lib/core/di/` (get_it). All BLoCs are provided at root in `main.dart`.

Localization: English + Filipino (Tagalog) via `lib/l10n/` ARB files.

### WebSocket Events
Socket.IO rooms: `user:{userId}` and `farm:{farmId}`. Handlers are in `src/sockets/` (sensorHandler, farmHandler, alertHandler).

### Prototype ↔ ThingSpeak
Each `Prototype` document stores a ThingSpeak `channel_id` and `read_api_key`. `syncService` iterates all Prototypes to sync their data independently — a single farm can have multiple ThingSpeak channels.

## Corn Crop Thresholds (hardcoded in `analyticsService.ts`)
- Temperature: 20–30°C
- Soil Moisture: 50–70%
- pH: 6.0–7.0
- Humidity: 50–70%

## Deployment
- Production: Nginx on port 10000 via `scripts/start.sh` + PM2
- Render: see `render.yaml` and `RENDER_DEPLOYMENT.md`
- Docker: `docker build -t maize-watch . && docker run -p 10000:10000 maize-watch`
