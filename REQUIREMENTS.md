# Cache — Requirements

## Overview
Cache is a native macOS menu-bar app that keeps the last 20 clipboard text items, lets users search the history, and paste a selected item into the frontmost app using a global hotkey. Clipboard history is in-memory only.

## Functional Requirements
- Track the last 20 clipboard text items (newest first).
- Deduplicate items: when a text already exists, move it to the top.
- Provide search across history (case-insensitive substring).
- Show history in a menu bar popover.
- Global hotkey opens the history UI (default: Cmd+Shift+V).
- Selecting an item pastes it into the frontmost app.
- Provide settings to change the hotkey.

## Non-Functional Requirements
- Privacy-first: in-memory only; no disk persistence.
- Low CPU usage (polling interval ~0.5–1s).
- Fast, responsive UI.

## Platform Constraints
- macOS 15+.
- SwiftUI-first app with minimal AppKit/Carbon bridging.

## Permissions
- Accessibility permission is required to simulate Cmd+V into the frontmost app.
- If permission is missing, the app should still copy to the clipboard and inform the user.

## Out of Scope
- Clipboard formats other than plain text.
- Sync across devices.
- Rich previews, image handling, or file history.

## Acceptance Criteria
- Copy 25 unique items → only the most recent 20 appear.
- Copy the same text twice → appears once at the top.
- Searching filters results correctly.
- Global hotkey opens the popover from any app.
- Selecting an item pastes into the frontmost app (with Accessibility granted).
- Without Accessibility, the app copies but does not paste and shows a warning.
