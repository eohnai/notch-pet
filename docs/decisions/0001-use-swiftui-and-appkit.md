# 0001: Use SwiftUI and AppKit

- Status: accepted
- Date: 2026-10-22

## Context

The user wants a notch interface and detachable pet on an M2 MacBook Air.
They explicitly selected SwiftUI/AppKit on 2026-10-22.

## Options

- **SwiftUI and AppKit**: direct access to macOS interface and window behavior; macOS-specific implementation.
- **Electron**: familiar web interface tools; adds runtime overhead and native integration work for window behavior.

## Decision

Use SwiftUI for interface content and AppKit for desktop window behavior.

## Reasoning

The user's explicit technology preference decides this choice.
Direct desktop integration supports the requested dragging and notch behavior. ^[inferred]

## Consequences

Target macOS first. Supporting another operating system would require a new presentation and window layer.

