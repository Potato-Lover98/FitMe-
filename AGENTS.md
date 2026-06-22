# FitMe+ — Health Tracking App Plan

A comprehensive **watchOS-only** app that unifies health metrics (blood pressure, temperature, fever likelihood, and many more) into a single Swift codebase. No iPhone app — everything runs on Apple Watch.

## Development Phases

Build is sequenced into phases. Each phase must build green (`xcodebuild`) and pass `swift test` before moving to the next. Phases are additive — later phases extend the scaffolding laid down in earlier ones. No phase is considered done until its verification command passes.

### Phase 0 — Project Foundation
- Create Xcode workspace with two targets: `FitMeWatch` (watchOS), `FitMeCore` (shared Swift package)
- Wire up `FitMeCore` as a dependency of `FitMeWatch`
- Set min deployment (watchOS 10+), bundle ID, capabilities (HealthKit, Bluetooth)
- Empty but launching app on watchOS Simulator
- **Verify:** `xcodebuild -scheme FitMeWatch` succeeds

### Phase 1 — Core Models & Domain Layer
- Define `VitalType` enum and all supported vitals
- Define data entities: `Reading`, `User`, `Goal`, `FeverRisk`
- Repository protocol interfaces (no implementations yet)
- Unit tests for model invariants (encoding/decoding, units)
- **Verify:** `swift test` passes

### Phase 2 — UI Scaffolding (Mock Data)
- Build all screens with hardcoded/mock data — no live data sources yet
- `FitMeWatch`: Onboarding, Dashboard (vital cards), Details (charts + history), Insights, Profile/Settings, Quick Add form, Live Activity placeholder, Complication placeholder
- Navigation, tabs, styling, accessibility — production-quality visual shell
- **Verify:** scheme builds; screens navigate with mock data

### Phase 3 — HealthKit Integration
- HealthKit permission request flow in onboarding
- `HealthKitManager`: queries, anchored queries, observer queries per `VitalType`
- Live HR/HRV streaming on Watch
- Wire real HealthKit data into the scaffolded UI (replace mock feeds)
- **Verify:** builds; HealthKit data renders in Dashboard on simulator

### Phase 4 — Bluetooth Accessories
- CoreBluetooth managers for thermometer and BP cuff
- Service/characteristic discovery, parsing protocols, `Reading` ingestion
- Pairing UI + permission prompts
- **Verify:** builds; manual scan/connect test on device

### Phase 5 — Persistence & Sync
- SwiftData store on Watch (reading history, goals, user profile)
- Repository implementations backed by SwiftData + HealthKit
- Migrate UI from mock repositories to real ones
- **Verify:** `swift test` for repository layer; data persists across app launches

### Phase 6 — Fever Engine (Rule-Based Baseline)
- Implement rule-based fever risk score (temperature + HR + HRV + symptoms)
- Implement rule-based BP anomaly detection and risk bands
- Wire into Insights and Dashboard
- This is the heuristic baseline the ML model must later beat
- **Verify:** `swift test` golden-value tests against fixed inputs

### Phase 7 — ML Model Training & Export (Offline)
- Curate datasets (MIMIC-style, PhysioNet), build feature pipeline
- Train small architecture (MLP / 1D-CNN / tiny transformer)
- Quantize (INT8) + prune; optional distillation
- Validate on held-out medical-grade set; must beat Phase 6 baseline on sensitivity/specificity/AUC
- Export `FitMeML.bin` + metadata JSON
- **Verify:** validation script passes and beats heuristic baseline

### Phase 8 — On-Device ML Integration
- `ModelLoader`, `Inferencer` (BNNS/Metal), `FeatureBuilder`, `PostProcessor`
- Load `FitMeML.bin` from bundle at runtime
- Replace rule-based Fever Engine outputs with ML inference where the model wins
- Golden-value inferencer unit tests
- **Verify:** `swift test` ML tests pass; inference runs on Neural Engine

### Phase 9 — Smart Insights & Analytics
- Trend detection, anomaly alerts, personalized recommendations
- Weekly/monthly report generation + PDF export
- Insights screen populated from real analytics pipeline
- **Verify:** builds; PDF export produces valid file

### Phase 10 — Notifications & Alerts
- High BP, fever onset, low SpO₂, missed medication, irregular rhythm
- Local notifications on Watch; threshold engine wired to ML output
- **Verify:** builds; scheduled notifications fire on simulator

### Phase 11 — Apple Watch Polish
- Complications (Modular, Circular, Corner) showing today's key vitals
- Live Activity for "Fever Watch" mode
- Siri intents + voice entry
- Glanceable dashboard refinement
- **Verify:** `xcodebuild -scheme FitMeWatch` succeeds; complications render

### Phase 12 — Polish, Testing & Release Prep
- Full unit + integration test pass
- Accessibility, localization, performance pass
- App Store metadata, icons, screenshots
- Final ML validation gate before shipping `FitMeML.bin`
- **Verify:** all build + test commands green; ready for submission

## Tech Stack & Architecture
- **Language:** Swift 5.9+, SwiftUI (declarative UI), SwiftConcurrency (async/await)
- **Platforms:** watchOS 10+ app, shared Swift package
- **Persistence:** SwiftData (on Watch), HealthKit (canonical store)
- **Min target:** Apple Watch (GPS + Cellular optional)
- **Project structure:** Xcode workspace with two targets: `FitMeWatch`, `FitMeCore` (shared Swift package)

## Core Features

### 1. Vitals Tracking
- **Blood Pressure** — manual entry + HealthKit import; charts, trends, WHO classification
- **Body Temperature** — manual entry, thermistor-enabled accessories, CHT (CoreBluetooth) integration
- **Fever Likelihood Engine** — combines temp, HR, HRV, user symptoms → risk score (0–100%)
- **Heart Rate / HRV** — HealthKit live streaming on Watch
- **SpO₂, Respiratory Rate** — HealthKit
- **Blood Oxygen, Glucose** (manual/CGM via HealthKit)
- **Weight / BMI / Body Fat** — HealthKit + manual
- **Sleep, Steps, Active Energy, Hydration, Mood/Stress** — HealthKit + manual logs

### 2. Smart Insights
- Trend detection, anomaly alerts (e.g., sustained elevated BP), personalized recommendations, weekly/monthly reports, exportable PDF

### 3. Notifications & Alerts
- High BP, fever onset, low SpO₂, missed medication, irregular rhythm (Watch)

### 4. Apple Watch Experience
- Complications (Modular, Circular, Corner) showing today's key vitals
- Live activity for "Fever Watch" mode, Siri intents, voice entry, glanceable dashboard

## Differentiator: On-Device ML Model (FitMeML)

The signature feature that sets FitMe+ apart is a **custom ML model trained from scratch** that powers all "super accurate" calculations and insights. No third-party APIs, no cloud calls — inference runs fully on-device.

### Design Principles
- **Trained from scratch** — no fine-tuned vendor models. The weights are our own, built from curated health datasets and validated against ground truth.
- **Tiny footprint** — model is aggressively quantized and pruned to a very small size so it ships inside the app bundle as a single `.bin` file (target: well under 5 MB; stretch goal < 1 MB). This keeps the app lightweight, fast to launch, and offline-capable.
- **Saved as `FitMeML.bin`** — a single binary blob loaded into memory at runtime via `Data(contentsOf:)` and fed into a minimal Swift inference layer (no Core ML dependency required, though optional export to `.mlmodel` / `.mlpackage` is supported for debugging).
- **On-device inference** — runs on the Neural Engine / GPU via Metal or BNNS, never leaves the device. Privacy-preserving and instant.
- **Superior accuracy** — model is evaluated against held-out medical-grade datasets; the target is to beat rule-based heuristics (e.g., fixed fever thresholds) by a meaningful margin on sensitivity and specificity.

### Responsibilities of the Model
1. **Fever likelihood score** — fuses temperature, HR, HRV, age, time-of-day, recent trends → calibrated probability (0–100%).
2. **Blood pressure anomaly detection** — flags readings that deviate from the user's personal baseline beyond expected variance.
3. **Risk stratification** — low / medium / high bands for each vital, personalized per user (not population-only thresholds).
4. **Trend forecasting** — short-horizon (next 24h) projection of key vitals with confidence intervals.
5. **Symptom correlation** — links self-reported symptoms to likely physiological causes.
6. **Sensor-augmented prediction** — the ML model consumes **live Apple Watch sensor readings** (HR, HRV, SpO₂, wrist temperature, respiratory rate) as real-time input features, combining them with historical trends to produce more accurate, personalized predictions than either the raw sensor values or the rule-based heuristics alone. The sensors feed the model, the model augments the sensors — both are fused into a single inference pipeline.

### Training Pipeline (offline, not shipped)
- **Data:** curated open datasets (MIMIC-style vitals, PhysioNet, self-collected opt-in samples with consent).
- **Architecture:** small MLP / 1D-CNN / tiny transformer — chosen for on-device constraints, not peak research accuracy.
- **Quantization:** INT8 or lower; weight pruning; optional knowledge distillation from a larger teacher.
- **Export:** serialize weights + minimal graph metadata → `FitMeML.bin`.
- **Validation:** hold out a medical-grade test set; report sensitivity/specificity/AUC; only ship if it beats heuristic baselines.

### Runtime Integration
```
FitMeCore
├── ML
│   ├── FitMeML.bin          (shipped in app bundle)
│   ├── ModelLoader.swift    (loads .bin into memory)
│   ├── Inferencer.swift     (forward pass via BNNS/Metal)
│   ├── FeatureBuilder.swift (HealthKit readings → feature vector)
│   └── PostProcessor.swift  (logits → calibrated probability + band)
```

## Architecture Layers

```
FitMeCore (shared)
├── Models          (Vitals, Reading, User, Goal)
├── HealthKit       (permissions, queries, observers)
├── Bluetooth       (thermometer/BP cuff managers)
├── FeverEngine     (risk scoring, rules, ML optional)
├── Repositories    (data access abstraction)
├── Analytics       (trend detection, report generation)
├── ML              (FitMeML.bin loader, inferencer, features)
└── Persistence     (SwiftData on Watch)

FitMeWatch
├── Dashboard       (cards per vital, today summary)
├── Details         (charts, history, add reading)
├── Insights        (weekly/monthly, recommendations)
├── Profile/Settings
├── Onboarding      (permissions, profile, goals)
├── Quick Add       (voice + crown)
├── Live Activities
└── Complications
```

## Data Models (key entities)
- `VitalType` enum (BP, temp, HR, HRV, SpO₂, glucose, weight, sleep, etc.)
- `Reading { id, vitalType, value, unit, source, date, notes, tags }`
- `FeverRisk { score, contributing factors, timestamp }`

## Build & Verify Commands
- `xcodebuild -scheme FitMeWatch -destination 'platform=watchOS Simulator,name=Apple Watch Series 9'` — build Watch app
- `swift test` — run FitMeCore unit tests (including ML inferencer golden-value tests)
- Run ML validation script before bumping `FitMeML.bin`: must beat heuristic baseline on held-out set

## Conventions
- Swift, SwiftUI, SwiftData, async/await throughout
- No third-party HTTP health APIs; HealthKit + on-device ML only
- All new vitals go through `VitalType` enum + a feature builder extension; the ML model is the single source of truth for "smart" numbers
- Never commit raw training datasets; only `FitMeML.bin` and its metadata JSON ship in the bundle