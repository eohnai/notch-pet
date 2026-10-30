import Testing
@testable import Pet

struct PetPresentationTests {
    @Test func singleIdleFrameRemainsVisible() throws {
        let idle = try #require(PetAnimation(frames: ["idle"], frameDurationMs: 150))
        let presentation = PetPresentation(idle: idle)
        #expect(presentation.animation(for: .idle).frames == ["idle"])
    }

    @Test func suppliedAnimationKeepsFramesAndTiming() throws {
        let idle = try #require(PetAnimation(frames: ["idle"], frameDurationMs: 150))
        let play = try #require(PetAnimation(frames: ["play-1", "play-2"], frameDurationMs: 90))
        let presentation = PetPresentation(idle: idle, animations: [.play: play])
        #expect(presentation.animation(for: .play) == play)
        #expect(presentation.animation(for: .idle) == idle)
    }

    @Test func everyMissingOptionalPoseFallsBackToIdle() throws {
        let idle = try #require(PetAnimation(frames: ["idle"], frameDurationMs: 150))
        let presentation = PetPresentation(idle: idle)
        for pose in PetPose.allCases {
            #expect(presentation.animation(for: pose) == idle)
        }
        #expect(PetAnimation(frames: [], frameDurationMs: 150) == nil)
        #expect(PetAnimation(frames: [""], frameDurationMs: 150) == nil)
        #expect(PetAnimation(frames: ["idle"], frameDurationMs: 0) == nil)
    }
}
