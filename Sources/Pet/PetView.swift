import AppKit
import SwiftUI

public struct PetView: View {
    private let presentation: PetPresentation
    private let pose: PetPose

    public init(presentation: PetPresentation, pose: PetPose = .idle) {
        self.presentation = presentation
        self.pose = pose
    }

    private var image: NSImage? {
        let requested = presentation.animation(for: pose).frames[0]
        let idle = presentation.animation(for: .idle).frames[0]
        return PetArtwork.url(for: requested).flatMap(NSImage.init(contentsOf:))
            ?? PetArtwork.url(for: idle).flatMap(NSImage.init(contentsOf:))
    }

    public var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
            } else {
                Image(systemName: "pawprint")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Pet artwork unavailable")
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(image == nil ? "Pet artwork unavailable" : "White lionhead rabbit")
    }
}
