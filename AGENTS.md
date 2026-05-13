# Kourt Project Notes

## Product Context

Kourt is a cross-platform iOS and Android app for fair court-sport matchmaking. Groups enter player names, choose the session setup, and the app generates rotations so players play and sit out as evenly as possible across sports such as badminton, tennis, and squash.

## Platform Approach

- The app uses Skip to share one Swift and SwiftUI codebase across iOS and Android.
- Prefer shared Swift implementations when feasible, especially for generation logic and view-model behavior.
- Design UI with SwiftUI idioms first, following Apple's Human Interface Guidelines where possible.
- The iOS experience should look and feel like a native Apple app, using standard navigation, controls, spacing, typography, and platform conventions unless there is a strong product reason not to.
- If a feature is difficult or unsupported on Android, get the iOS implementation working first and isolate platform differences with compiler/platform checks rather than weakening the iOS experience.
- Android-specific behavior may require extra Kotlin/Java or Skip configuration; keep those changes focused under `Android/` or Skip config when possible.

## Repository Layout

- `Sources/Kourt`: shared SwiftUI app, views, components, resources, and app-level view model.
- `Sources/KourtShared`: platform-neutral models and matchmaking/session generation logic.
- `Tests/KourtSharedTests`: generator and session-state tests covering fairness, validity, consistency, and edge cases.
- `Darwin`: iOS app shell, Xcode project, app icon, entitlements, widget, and App Store metadata.
- `Android`: generated/native Android app project, Gradle config, launcher assets, and Play Store metadata.
- `site`: Astro marketing/privacy site.
- `scripts`: release, changelog, version, and screenshot helpers.

## Development Commands

- `swift test`: run shared Swift tests.
- `skip test`: run platform parity tests, including transpiled Kotlin/JUnit tests.
- `skip verify`: validate the Skip project.
- `xcodebuild -project Darwin/Kourt.xcodeproj -scheme "Kourt App"`: build via Xcode project when needed.

## Engineering Guidance

- Keep core matchmaking rules in `Sources/KourtShared` with tests before wiring UI behavior.
- Preserve deterministic invariants in tests even when generation uses random tie-breaking.
- Prefer native SwiftUI components and Apple platform patterns over custom controls for common interactions.
- Avoid platform-only APIs in shared views unless guarded or encapsulated.
- Prefer small, explicit model changes; sessions are `Codable`, `Hashable`, and `Sendable`, so schema changes can affect persistence and sharing.
- Localized user-facing strings should live in `Sources/Kourt/Resources/Localizable.xcstrings`.
- Do not revert unrelated local changes; this repo may have active user edits.
