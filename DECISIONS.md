# Decisions

## Purpose

This document explains the key architectural and technology decisions made for this Flutter assignment project. The focus is on practical engineering tradeoffs, assignment scope, and implementation clarity rather than production-level optimization.

## 1. Why Firebase Was Chosen

Firebase was selected as the backend platform because it provides the fastest path to a working realtime prototype for this assignment.

### Reasons

- Firestore offers built-in realtime snapshot listeners
- Firebase integrates well with Flutter
- it reduces backend setup overhead
- it is suitable for chat, scheduling, room presence, and session log persistence
- it allows both apps to share the same cloud state with minimal infrastructure work

### Decision Impact

Using Firebase allowed the project to focus on product behavior and app integration instead of building and hosting a custom backend.

### Tradeoff

- less control than a custom backend
- security and data modeling must be designed carefully in a real production system
- Firestore structures can become harder to evolve at scale if not planned well

## 2. Why Riverpod Was Chosen

Riverpod was chosen as the state management solution because it provides a clean and scalable way to manage services, streams, and UI state in Flutter.

### Reasons

- simple dependency injection for shared services
- strong fit for stream-based Firestore data
- keeps widgets thin and reactive
- avoids tightly coupling UI to backend logic
- supports modular growth better than ad hoc `setState` patterns

### Decision Impact

Riverpod made it easier to expose:

- Firestore-backed streams
- call session state
- appointment request state
- session history state

This improved separation between presentation and integration logic.

### Tradeoff

- slightly more setup than very small Flutter state approaches
- requires discipline in provider organization

## 3. Why Hive Was Chosen

Hive was chosen for local persistence because it is lightweight, easy to integrate, and sufficient for assignment-scale caching needs.

### Reasons

- fast local key-value storage
- simple Flutter integration
- low setup overhead
- suitable for caching session logs locally

### Decision Impact

Hive supports a simple local-first layer for session history without introducing unnecessary persistence complexity.

### Tradeoff

- not intended here as a full relational or sync engine
- limited compared to more advanced offline-first database approaches
- manual care is needed around serialization and cache consistency

## 4. Why Jitsi Replaced 100ms

Jitsi was chosen in place of 100ms to simplify RTC integration for assignment scope.

### Reasons

- Jitsi provides a faster path to working video calls
- it avoids the additional setup and orchestration complexity often involved in more customizable RTC platforms
- it is sufficient for room-based trainer/member calling
- it works well with a deterministic shared room strategy

### Decision Impact

Replacing 100ms with Jitsi reduced integration risk and kept the focus on:

- scheduling
- join/leave flow
- session lifecycle logging
- cross-app communication behavior

### Tradeoff

- less flexibility than a more programmable RTC stack
- less control over custom media workflows
- fewer product-level customization options if the system were scaled further

## 5. Why StreamController Was Retained

`StreamController` was retained in the call layer because it remains a practical tool for broadcasting in-process session state that does not come directly from Firestore.

### Reasons

- call session state includes local lifecycle information
- Jitsi callbacks need to push session changes immediately
- not all call state belongs in Firestore
- it works well alongside Riverpod `StreamProvider`

### Decision Impact

This allowed the architecture to separate:

- remote shared state in Firestore
- local active call state in memory

Riverpod then exposes both cleanly to the UI.

### Tradeoff

- introduces another reactive mechanism in addition to Firestore streams
- requires careful lifecycle cleanup to avoid stale state

## 6. Local-First Strategy

The project uses a lightweight local-first strategy for session logs.

### Strategy

- write session data to local Hive cache
- sync the same session data to Firestore
- read cached session data immediately where available
- continue treating Firestore as the remote source of truth

### Why This Approach Was Chosen

- improves perceived responsiveness
- preserves recently synced session history locally
- keeps offline behavior better than remote-only reads
- stays simple enough for assignment scope

### Important Clarification

This is not a full offline-first synchronization architecture. It is a practical local-cache-first approach for a constrained feature set.

## 7. Tradeoffs Made Under Time Constraints

Several decisions were made deliberately to keep the assignment implementable within limited time.

### Simplifications

- static trainer/member identities in some flows
- simplified scheduling model instead of full calendar logic
- Firestore used directly through services without extra repository layers
- minimal role/auth complexity
- limited offline conflict handling
- lightweight session history UI without advanced filtering/search

### Why These Tradeoffs Were Acceptable

- the assignment priority was working end-to-end functionality
- modularity was preserved where it mattered most
- complexity was avoided where it would not materially improve evaluation value

## 8. Scalability Considerations

Even though this is an assignment-focused implementation, some decisions were made with future extension in mind.

### Positive decisions for future scale

- shared module for common business logic
- service layer isolation for Firebase/Jitsi concerns
- reusable session model
- Riverpod-based dependency and stream management
- Firestore-backed realtime sync across both apps

### Areas that would need improvement for larger scale

- stronger authentication and role management
- production-grade Firestore rules
- repository/domain abstraction if business logic grows
- richer offline sync and retry handling
- pagination for chats and history
- improved RTC observability and error recovery
- support for multiple trainers, members, and parallel session structures

## 9. Overall Decision Philosophy

The guiding principle for this project was to keep the architecture simple, understandable, and assignment-appropriate while still demonstrating sound engineering structure.

Key priorities were:

- end-to-end feature completeness
- clear separation of shared and app-specific logic
- maintainable integration patterns
- minimal unnecessary abstraction

## Summary

Firebase, Riverpod, Hive, Jitsi, and StreamController were chosen because together they provide a practical balance of speed, clarity, and functionality for a dual-app Flutter realtime communication assignment. The design intentionally favors delivery and readability, while still leaving room for future evolution if the project were extended beyond assignment scope.
