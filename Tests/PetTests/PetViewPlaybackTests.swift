import Testing
@testable import Pet

@MainActor
struct PetViewPlaybackTests {
    @Test func requestedPoseUsesItsOwnFrameTiming() throws {
        let idle = try #require(PetAnimation(frames: ["idle"], frameDurationMs: 100))
        let play = try #require(PetAnimation(frames: ["play-first", "play-second"], frameDurationMs: 250))
        let view = PetView(presentation: PetPresentation(idle: idle, animations: [.play: play]), pose: .play)

        #expect(view.frame(at: 0, reduceMotion: false) == "play-first")
        #expect(view.frame(at: 0.249, reduceMotion: false) == "play-first")
        #expect(view.frame(at: 0.25, reduceMotion: false) == "play-second")
        #expect(view.frame(at: 0.5, reduceMotion: false) == "play-first")
    }

    @Test func missingPoseUsesIdlePlayback() throws {
        let idle = try #require(PetAnimation(frames: ["idle-first", "idle-second"], frameDurationMs: 100))
        let view = PetView(presentation: PetPresentation(idle: idle), pose: .attention)

        #expect(view.frame(at: 0, reduceMotion: false) == "idle-first")
        #expect(view.frame(at: 0.1, reduceMotion: false) == "idle-second")
        #expect(view.frame(at: 0.2, reduceMotion: false) == "idle-first")
    }

    @Test func inactiveInputsAndSingleFrameKeepStableArtwork() throws {
        let idle = try #require(PetAnimation(frames: ["first", "second"], frameDurationMs: 100))
        let presentation = PetPresentation(idle: idle)
        for (visible, sleeping, reduceMotion) in [(false, false, false), (true, true, false), (true, false, true)] {
            let view = PetView(presentation: presentation, isVisible: visible, isSleeping: sleeping)
            #expect(view.frame(at: 0.1, reduceMotion: reduceMotion) == "first")
            #expect(view.frame(at: 12.3, reduceMotion: reduceMotion) == "first")
        }
        let single = try #require(PetAnimation(frames: ["only"], frameDurationMs: 100))
        let view = PetView(presentation: PetPresentation(idle: single))
        #expect(view.frame(at: 12.3, reduceMotion: false) == "only")
    }
}
