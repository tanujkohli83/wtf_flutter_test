# Architecture

## Overview

This project is a dual-app Flutter realtime communication system built for a trainer/member workflow. It consists of:

- `guru_app`: member-facing application
- `trainer_app`: trainer-facing application
- `shared`: shared models, services, and communication logic

The architecture is intentionally simple and assignment-focused. It prioritizes clear module boundaries, realtime behavior, and reusable shared logic over production-scale complexity.

## High-Level Design

The system uses a shared-service approach:

- presentation and app-specific flows live in each Flutter app
- shared business logic and integration services live in `shared`
- Firestore acts as the remote persistence and sync layer
- Hive acts as a lightweight local cache
- Riverpod manages dependency injection and state access
- Jitsi provides video meeting infrastructure

## Module Organization

### `guru_app`

Contains member-specific UI and flows:

- dashboard
- chat
- appointment request flow
- call join flow
- session history
- member feedback after calls

### `trainer_app`

Contains trainer-specific UI and flows:

- dashboard
- request management
- chat
- call start flow
- session history
- trainer notes after calls

### `shared`

Contains reusable cross-app logic:

- models
- Firestore-backed services
- call session management
- StreamController-based realtime session broadcasting
- session log persistence
- shared widgets for call and feedback flows

## State Management

Riverpod is used as the primary state management mechanism.

It is responsible for:

- service provisioning
- stream exposure to UI
- app-level reactive state
- separating UI from integration logic

Provider types are used according to responsibility:

- `Provider` for service injection
- `StreamProvider` for Firestore-backed reactive data
- `NotifierProvider` for local UI/application state

This keeps widgets thin and moves orchestration into services and controllers.

## Service Layer

The service layer is centered in `shared` and provides the main application integrations.

### Core services

- `RealtimeChatService`
  - manages chat messages and typing state
- `AppointmentRequestService`
  - manages scheduling requests and approval flow
- `CallService`
  - handles Jitsi room participation, room presence, and in-call state
- `SessionLogService`
  - manages Hive caching and Firestore sync for completed sessions

This approach avoids duplicating communication logic across the two Flutter apps.

## Data Flow

### Scheduling Flow

1. Member creates an appointment request.
2. Request is stored in Firestore.
3. Trainer watches pending requests in realtime.
4. Trainer approves or declines the request.
5. Both apps react to the updated Firestore state.
6. Approved requests appear as upcoming sessions.

### Chat Flow

1. A user sends a message from either app.
2. The message is written to Firestore through the shared chat service.
3. Firestore snapshots update both apps in realtime.
4. Riverpod stream providers rebuild the relevant screens.

### Session Logging Flow

1. Trainer and member join the Jitsi call.
2. `CallService` detects conference join.
3. A session log is created with `startedAt`.
4. When the call ends, feedback is collected.
5. `endedAt` and `duration` are written automatically.
6. The session is saved locally in Hive and remotely in Firestore.
7. Session history screens update from the shared data source.

## Realtime Sync Flow

Realtime synchronization is driven primarily by Firestore snapshot streams.

### Firestore responsibilities

- appointment requests
- call room presence
- session log persistence
- chat data

### Stream responsibilities

- Firestore streams provide remote updates
- `StreamController` in the call layer broadcasts active in-memory session state
- Riverpod `StreamProvider` adapts both remote and in-process streams to the UI

This design supports:

- realtime cross-device communication
- shared room presence updates
- immediate UI refresh on scheduling/chat/session changes

## Local Caching

Hive is used as a lightweight local cache for session logs.

### Purpose of caching

- retain session history locally
- reduce dependence on immediate network reads
- provide faster access to previously synced session data

### Cache scope

- session logs only in the current assignment implementation

Hive is not used here as a full offline-first database. Firestore remains the remote source of truth, while Hive improves local responsiveness and persistence simplicity.

## Jitsi Video Calling

Jitsi Meet is used for RTC/video sessions.

### Integration model

- a deterministic room id is generated from trainer/member ids
- both apps join the same room during the scheduled window
- call presence is also mirrored in Firestore through `CallService`
- video session lifecycle is linked to session log creation/completion

This keeps RTC infrastructure simple while allowing the app to retain structured session history outside the meeting itself.

## Session Logs

Session logs are modeled as reusable shared records containing:

- session id
- trainer/member identity
- session focus
- start time
- end time
- calculated duration
- member rating
- trainer notes
- member notes

They are consumed by both apps for completed session history.

## Scalability Decisions

The current architecture makes a few deliberate scalability-friendly decisions while remaining simple.

### Positive scalability choices

- shared module reduces duplication across two apps
- service-based integration isolates Firestore/Jitsi logic
- Riverpod providers keep UI loosely coupled from data sources
- session logging uses a reusable shared model
- Firestore streams support realtime updates without custom socket infrastructure

### Intentional simplifications

- static demo identities are still used in places
- no repository/domain abstraction layers beyond current service boundaries
- no advanced offline conflict resolution
- no sharding, pagination, or batching strategies yet

These tradeoffs are appropriate for assignment scope while still leaving room for extension.

## Future Architectural Extensions

If this system were expanded beyond assignment scope, likely next steps would include:

- role-based authentication and profile management
- stricter Firestore security rules
- repository interfaces between services and UI/application layers
- notification/reminder infrastructure
- stronger offline synchronization strategy
- analytics and monitoring
- support for multiple trainers, members, and richer scheduling logic

## Summary

The architecture uses two Flutter apps over a shared communication layer, with Firestore for realtime sync, Hive for local caching, Riverpod for state management, and Jitsi for video calling. It is modular, readable, and intentionally scoped to meet assignment requirements without unnecessary complexity.
