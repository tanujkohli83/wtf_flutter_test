# AI Ledger

## Document Purpose

This ledger records AI-assisted contributions used during the development of this Flutter assignment project. It is intended to help reviewers understand:

- what kinds of prompts were used
- why AI assistance was used
- which implementation areas were influenced by AI
- where human judgment and integration decisions were still required

This document is structured for auditability rather than narrative detail.

## Project Context

- Project: Flutter dual-app trainer/member communication assignment
- Repository modules:
  - `guru_app`
  - `trainer_app`
  - `shared`
- Core technologies:
  - Flutter
  - Riverpod
  - Firebase / Firestore
  - Hive
  - Jitsi Meet SDK

## Usage Summary

AI assistance was used for:

- implementation planning
- code generation for assignment-focused features
- architecture suggestions
- UI scaffolding
- debugging support
- documentation generation

AI assistance was not treated as a source of truth by itself. All outputs required manual review, adaptation to the codebase, and validation through static analysis and local project context.

## Prompt Log

### Prompt 1

- Timestamp: `[YYYY-MM-DD HH:MM placeholder]`
- Commit Reference: `[commit-hash placeholder]`
- Prompt Summary:
  - Implement session logging for the Flutter trainer/member communication app.
- Purpose:
  - Add session start/end capture, duration calculation, feedback collection, and local/remote persistence.
- Expected Output:
  - reusable session model
  - Hive + Firestore session persistence
  - Riverpod-compatible architecture
  - post-call feedback flow
  - latest-first session history UI
- Generated / Assisted Components:
  - shared session log model
  - session log service
  - call lifecycle integration
  - feedback bottom sheet
  - updated history screens

### Prompt 2

- Timestamp: `[YYYY-MM-DD HH:MM placeholder]`
- Commit Reference: `[commit-hash placeholder]`
- Prompt Summary:
  - Generate a professional README for a Flutter dual-app realtime trainer/member communication assignment.
- Purpose:
  - Produce submission-quality project documentation for reviewers.
- Expected Output:
  - project overview
  - setup instructions
  - architecture summary
  - Firebase and Jitsi configuration guidance
  - limitations and future scope
- Generated / Assisted Components:
  - root `README.md`

### Prompt 3

- Timestamp: `[YYYY-MM-DD HH:MM placeholder]`
- Commit Reference: `[commit-hash placeholder]`
- Prompt Summary:
  - Generate a professional AI ledger for a Flutter assignment project.
- Purpose:
  - Document AI-assisted contributions in a structured and reviewer-friendly format.
- Expected Output:
  - prompt records
  - purpose mapping
  - generated component tracking
  - architecture/debugging notes
- Generated / Assisted Components:
  - root `AI_LEDGER.md`

## Detailed AI-Assisted Areas

### 1. Architecture Assistance

AI was used to help structure the solution around a simple modular approach:

- `guru_app` for the member experience
- `trainer_app` for the trainer experience
- `shared` for reusable models, services, and realtime logic

AI-assisted decisions included:

- keeping shared communication logic in `shared`
- using Riverpod providers for service/state access
- separating remote data services from presentation screens
- using a single reusable session model across both apps

Human review determined final fit with the repository layout and assignment scope.

### 2. Firebase Integration Help

AI assistance was used to support integration patterns involving:

- Firebase initialization flow
- anonymous authentication fallback
- Firestore-backed chat and appointment request flows
- session log persistence to Firestore
- collection naming consistency

AI-generated suggestions were adapted to match:

- the existing Firebase setup in both apps
- the existing shared service style
- the assignment’s simplified data model

### 3. RTC Integration Help

AI assistance was used for RTC/video call integration involving:

- Jitsi Meet join/leave lifecycle handling
- room-based session tracking
- linking call events to session log creation/completion
- post-call feedback flow after meeting termination

AI-assisted output helped with:

- defining a clean session lifecycle
- identifying where to hook call join and leave events
- keeping session start/end logic centralized

Final behavior still required manual alignment with the existing call service and screen flow.

### 4. Hive Local Cache Assistance

AI was used to help implement local caching for session logs.

Assisted tasks:

- creating a simple cache service pattern
- storing session logs locally before/alongside Firestore sync
- preserving latest-first retrieval for history screens

Manual validation was required to ensure local serialization remained compatible with the chosen storage format.

### 5. UI / UX Assistance

AI assistance supported lightweight assignment-focused UI generation for:

- session history screens
- upcoming/completed grouping
- sort controls
- feedback bottom sheet
- modern card-based presentation

The generated UI was kept intentionally simple and practical, rather than production-polished, to fit the assignment scope.

## Debugging Assistance Log

### Debugging Area 1: Dependency / Package Resolution

- Timestamp: `[YYYY-MM-DD HH:MM placeholder]`
- Commit Reference: `[commit-hash placeholder]`
- Issue:
  - newly added package usage required dependency refresh
- AI Assistance:
  - identified dependency resolution mismatch after shared module changes
  - suggested running package resolution in affected modules
- Result:
  - package configuration updated and analysis rerun

### Debugging Area 2: Session Lifecycle Hooking

- Timestamp: `[YYYY-MM-DD HH:MM placeholder]`
- Commit Reference: `[commit-hash placeholder]`
- Issue:
  - call termination flow needed to preserve enough session context for feedback and log completion
- AI Assistance:
  - suggested capturing prior session state before provider reset
  - recommended post-call bottom sheet flow after leave/termination
- Result:
  - feedback capture integrated into both trainer and member call screens

### Debugging Area 3: Local Serialization

- Timestamp: `[YYYY-MM-DD HH:MM placeholder]`
- Commit Reference: `[commit-hash placeholder]`
- Issue:
  - local cache format and Firestore-oriented serialization needed separation
- AI Assistance:
  - highlighted the need for a cache-safe JSON representation
- Result:
  - local cache serialization path was adjusted for stable Hive storage

### Debugging Area 4: Static Analysis Cleanup

- Timestamp: `[YYYY-MM-DD HH:MM placeholder]`
- Commit Reference: `[commit-hash placeholder]`
- Issue:
  - post-implementation analyzer failures
- AI Assistance:
  - surfaced listener callback mistakes and small code issues
- Result:
  - analyzer issues resolved and modules rechecked

## Generated Components Register

The following areas were materially AI-assisted during implementation or documentation:

- `README.md`
- `AI_LEDGER.md`
- session log model design
- session log service structure
- call lifecycle session integration
- feedback bottom sheet flow
- session history screen restructuring
- setup/configuration documentation

## Architectural Decisions Influenced by AI

The following project decisions were supported by AI suggestions, but finalized through human review:

- use a shared module for reusable communication/session logic
- keep Riverpod at the service/provider orchestration layer
- persist session logs in both Hive and Firestore
- treat Firestore as remote source of truth
- trigger session start on conference join rather than prejoin
- trigger session completion on call exit with a separate feedback step
- keep the implementation assignment-focused rather than over-engineered

## Human Review and Validation

All AI-assisted outputs required manual review for:

- compatibility with the existing repository structure
- consistency with Flutter and Riverpod patterns already in use
- dependency correctness
- compile/analyze validation
- alignment with assignment requirements

Validation activities included:

- reading existing code before changes
- integrating AI-generated structure into actual module boundaries
- static analysis checks
- dependency refresh where needed
- manual review of generated documentation

## Known Constraints of AI Assistance

Reviewers should note the following:

- AI-generated code may accelerate scaffolding but does not replace engineering review.
- AI-generated integration logic may require repository-specific adaptation.
- RTC and Firebase flows especially require verification in the real runtime environment.
- Documentation generated by AI is useful for structure, but still needs factual alignment with the actual project state.

## Placeholder Audit Fields

Use the following placeholders if a formal review trail is required:

### Session Logging Work

- Timestamp Started: `[placeholder]`
- Timestamp Completed: `[placeholder]`
- Related Commit(s): `[placeholder]`
- Reviewer Notes: `[placeholder]`

### Documentation Work

- Timestamp Started: `[placeholder]`
- Timestamp Completed: `[placeholder]`
- Related Commit(s): `[placeholder]`
- Reviewer Notes: `[placeholder]`

### Final Submission Review

- Review Timestamp: `[placeholder]`
- Final Commit Reference: `[placeholder]`
- Submission Tag / Version: `[placeholder]`
- Reviewer Sign-off: `[placeholder]`

## Reviewer Notes

This ledger is intentionally concise and structured. It is designed to show where AI was used without overstating autonomy or hiding the need for manual engineering judgment.
