import CoreGraphics
import Foundation

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
