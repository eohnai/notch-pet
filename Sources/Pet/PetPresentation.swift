public enum PetPose: String, CaseIterable, Sendable {
    case idle, play, sleep, running, attention, complete, drag
}

public struct PetAnimation: Equatable, Sendable {
    public let frames: [String]
    public let frameDurationMs: Int

    public init?(frames: [String], frameDurationMs: Int) {
        guard !frames.isEmpty, frames.allSatisfy({ !$0.isEmpty }), frameDurationMs > 0 else { return nil }
        self.frames = frames
        self.frameDurationMs = frameDurationMs
    }
}

public struct PetPresentation: Sendable {
    private let idle: PetAnimation
    private let animations: [PetPose: PetAnimation]

    public init(idle: PetAnimation, animations: [PetPose: PetAnimation] = [:]) {
        self.idle = idle
        self.animations = animations
    }

    public func animation(for pose: PetPose) -> PetAnimation {
        pose == .idle ? idle : animations[pose] ?? idle
    }
}
