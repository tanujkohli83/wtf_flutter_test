# Flutter Realtime Trainer/Member Communication Assignment

## Project Overview

This repository contains a dual-app Flutter assignment for realtime communication between a trainer and a member. The solution is split into:

- `guru_app`: member-facing app
- `trainer_app`: trainer-facing app
- `shared`: shared models, services, and communication logic

The assignment demonstrates a practical mobile architecture for chat, call scheduling, video sessions, and session history tracking using Firebase, Hive, Riverpod, and Jitsi Meet.

## Features

- Realtime trainer/member chat using Firebase
- Appointment scheduling and approval flow
- Jitsi Meet video call join/start flow
- Session lifecycle logging
- Automatic session start, end, and duration capture
- Post-session member rating and notes
- Post-session trainer notes
- Hive local cache for session data
- Firestore sync for shared cloud persistence
- Session history screens for upcoming and completed sessions
- Sortable latest-first completed session lists
- Shared business logic through a reusable `shared` module

## Architecture

The project follows a simple modular Flutter structure suitable for an assignment submission.

### Modules

- `guru_app`
  - Member UI
  - Session history for upcoming and completed trainer sessions
  - Call join flow
  - Post-call rating and member feedback

- `trainer_app`
  - Trainer UI
  - Session history for upcoming and completed member sessions
  - Call start flow
  - Post-call trainer notes

- `shared`
  - Shared models
  - Realtime services
  - Call service
  - Appointment request service
  - Session log service
  - Shared widgets for call and feedback flows

### State Management

- Riverpod is used for:
  - service injection
  - stream-based Firestore state
  - call session state
  - appointment/session history state

### Data Flow

1. Member schedules a session request.
2. Trainer reviews and approves/declines the request.
3. During the scheduled slot, both users can enter the shared Jitsi room.
4. Session logging starts when the video call is joined.
5. Session logging ends when the call is left/terminated.
6. A post-call feedback sheet captures rating/notes.
7. Session data is stored in Hive locally and synced to Firestore.

## Tech Stack

- Flutter
- Dart
- Riverpod
- Firebase Core
- Cloud Firestore
- Firebase Auth
- Hive / Hive Flutter
- Jitsi Meet Flutter SDK
- Intl

## Project Structure

```text
.
â”œâ”€â”€ guru_app/
â”œâ”€â”€ trainer_app/
â”œâ”€â”€ shared/
â”œâ”€â”€ README.md
â”œâ”€â”€ ARCHITECTURE.md
â”œâ”€â”€ DECISIONS.md
â””â”€â”€ AI_LEDGER.md
```

## Setup Instructions

### Prerequisites

- Flutter SDK installed
- Dart SDK installed
- Android Studio or VS Code
- Firebase project configured
- A device/emulator for each app if testing both roles separately

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd wtf_flutter_test
```

### 2. Install dependencies

Run package resolution in all three modules:

```bash
cd shared
flutter pub get
```

```bash
cd ../guru_app
flutter pub get
```

```bash
cd ../trainer_app
flutter pub get
```

## Firebase Configuration

This project uses Firebase for authentication, chat, scheduling, room presence, and session log sync.

### Required Firebase services

- Firebase Authentication
- Cloud Firestore

### Configuration steps

1. Create a Firebase project.
2. Add Android/iOS/Web apps for both `guru_app` and `trainer_app` as needed.
3. Replace generated Firebase config files if required:
   - `guru_app/lib/firebase_options.dart`
   - `trainer_app/lib/firebase_options.dart`
   - platform-specific files such as `google-services.json` / `GoogleService-Info.plist`
4. Enable Anonymous Authentication if you want the provided anonymous sign-in flow to work cleanly.
5. Create Firestore rules appropriate for assignment/demo use.

### Firestore collections used

- `appointment_requests`
- `call_rooms`
- `session_logs`
- chat-related collections managed by the shared realtime chat service

## Jitsi Setup

Jitsi Meet is used for video calling via the Flutter SDK.

### Current setup

- The app uses a shared room naming strategy based on trainer/member ids.
- Default server URL is configured as:

```text
https://meet.jit.si
```

### Notes

- No custom Jitsi deployment is required for basic assignment evaluation.
- Supported call platforms in the current implementation are Android, iOS, and Web.
- Ensure platform permissions are correctly configured if testing on physical devices.

## Running Both Apps

Run the apps separately from their own module directories.

### Run member app

```bash
cd guru_app
flutter run
```

### Run trainer app

```bash
cd trainer_app
flutter run
```

### Recommended test flow

1. Launch `trainer_app`.
2. Launch `guru_app`.
3. Create a session request from the member side.
4. Approve it from the trainer side.
5. Join the scheduled call from both apps.
6. End the call and submit feedback.
7. Review completed session history on both sides.

## Screenshots

Add screenshots here before final submission.

### Member App

- `[Placeholder]` Dashboard
- `[Placeholder]` Chat screen
- `[Placeholder]` Appointment scheduling
- `[Placeholder]` Session history
- `[Placeholder]` Video call / feedback sheet

### Trainer App

- `[Placeholder]` Dashboard
- `[Placeholder]` Request management
- `[Placeholder]` Chat screen
- `[Placeholder]` Session history
- `[Placeholder]` Video call / feedback sheet

## Session Logging Summary

The assignment includes a simple session logging implementation:

- session starts when the video call joins
- session ends when the call leaves or terminates
- duration is calculated automatically from `startedAt` and `endedAt`
- member rating is captured after call end
- trainer notes and member notes are stored with the session
- session data is cached locally in Hive
- session data is synced to Firestore for shared visibility

## Assumptions

- The system models one trainer and one member conversation flow for assignment simplicity.
- Anonymous Firebase authentication is acceptable for demo purposes.
- Firestore is used as the main remote source of truth.
- Hive is used only as a lightweight local cache, not as an offline conflict-resolution layer.
- Jitsi room ids are deterministic and shared between trainer/member for easy joining.
- Scheduling is implemented as a simple request and approval flow, not a full calendar system.

## Known Limitations

- No production-grade authentication or role management
- No advanced Firestore security rules included in this repository
- Limited offline conflict handling
- Jitsi session recovery/reconnect flow is minimal
- Scheduling is simplified for assignment scope
- Static user identities are currently used in parts of the demo flow
- No automated integration tests for Firebase/Jitsi scenarios

## Future Improvements

- Add proper login and role-based user profiles
- Add robust Firestore security rules
- Introduce repository abstractions and domain interfaces if the project grows
- Support multi-trainer and multi-member relationships
- Add notifications for request approval and session start reminders
- Add pagination and filtering for chat/session history
- Improve offline sync and retry behavior
- Add automated widget, integration, and end-to-end tests
- Add production-ready analytics and error monitoring

## Assignment Notes

This implementation is intentionally assignment-focused:

- architecture is kept simple and readable
- business logic is centralized in `shared` where practical
- UI is modern but lightweight
- implementation prioritizes core trainer/member communication flows over production hardening

## Author

Assignment submission repository.
