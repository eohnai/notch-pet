import CoreGraphics
import Foundation

public enum NotchPresentation {
    public static func activeProviders(_ sessions: [SessionSnapshot]) -> Set<IntegrationAgent> {
        Set(sessions.filter { $0.status != .ended }.compactMap { IntegrationAgent(rawValue: $0.key.agent) })
    }

    public static func ordered(_ sessions: [SessionSnapshot]) -> [SessionSnapshot] {
        let rank: (SessionSnapshot) -> Int = { session in
            if session.pendingRequests.contains(where: \.isConfirmed) { return 0 }
            switch session.status {
            case .responseReady: return 1
            case .working: return 2
            case .idle: return 3
            case .unknown, .questionNeeded, .approvalNeeded: return 4
            case .ended: return 5
            }
        }
        return sessions.sorted { left, right in
            let a = rank(left), b = rank(right)
            if a != b { return a < b }
            if left.key.agent != right.key.agent { return left.key.agent < right.key.agent }
            return left.key.sessionID.utf8.lexicographicallyPrecedes(right.key.sessionID.utf8)
        }
    }

    public static func selection(_ current: SessionKey?, sessions: [SessionSnapshot]) -> SessionKey? {
        if let current, sessions.contains(where: { $0.key == current }) { return current }
        return ordered(sessions).first?.key
    }
}

/// Screen coordinates are supplied by AppKit; the model has no window or process dependencies.
public enum NotchPlacement {
    public static func frame(screen: CGRect, safeTop: CGFloat, notchWidth: CGFloat,
                             expanded: Bool) -> CGRect? {
        guard [screen.origin.x, screen.origin.y, screen.width, screen.height, safeTop, notchWidth]
            .allSatisfy({ $0.isFinite }), screen.width > 24, screen.height > 44,
              safeTop >= 0, notchWidth >= 0, safeTop <= screen.height - 12 else { return nil }
        let header = max(32, safeTop)
        let width = min(expanded ? 560 : max(220, notchWidth + 48), screen.width - 24)
        let height = min(header + (expanded ? 280 : 0), screen.height - 12)
        return CGRect(x: screen.midX - width / 2, y: screen.maxY - height,
                      width: width, height: height)
    }
}
