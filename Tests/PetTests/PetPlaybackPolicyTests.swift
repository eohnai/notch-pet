import Testing
@testable import Pet

struct PetPlaybackPolicyTests {
    @Test func visibleAwakePlaybackAdvancesAndLoops() throws {
        let animation = try #require(PetAnimation(frames: ["first", "second", "third"], frameDurationMs: 250))
        let policy = PetPlaybackPolicy(animation: animation, isVisible: true,
                                       isSleeping: false, reduceMotion: false)

        #expect(policy.shouldAnimate)
        for (elapsed, expected) in [(0.0, "first"), (0.249, "first"), (0.25, "second"),
                                    (0.499, "second"), (0.5, "third"), (0.749, "third"),
                                    (0.75, "first"), (1.0, "second"), (750.5, "third")] {
            #expect(policy.frame(at: elapsed) == expected)
        }
        for elapsed in [-1.0, Double.nan, Double.infinity, -Double.infinity] {
            #expect(policy.frame(at: elapsed) == "first")
        }
        #expect(animation.frames.contains(policy.frame(at: Double.greatestFiniteMagnitude)))
    }

    @Test func singleFrameNeedsNoAnimation() throws {
        let animation = try #require(PetAnimation(frames: ["idle"], frameDurationMs: 150))
        let policy = PetPlaybackPolicy(animation: animation, isVisible: true,
                                       isSleeping: false, reduceMotion: false)

        #expect(!policy.shouldAnimate)
        for elapsed in [0.0, 0.15, 10.0, Double.greatestFiniteMagnitude] {
            #expect(policy.frame(at: elapsed) == "idle")
        }
    }

    @Test func hiddenPlaybackRetainsFirstFrame() throws {
        let animation = try #require(PetAnimation(frames: ["first", "second"], frameDurationMs: 250))
        let policy = PetPlaybackPolicy(animation: animation, isVisible: false,
                                       isSleeping: false, reduceMotion: false)

        #expect(!policy.shouldAnimate)
        for elapsed in [0.0, 0.25, 0.75, 100.25] {
            #expect(policy.frame(at: elapsed) == "first")
        }
    }

    @Test func sleepingPlaybackRetainsFirstFrame() throws {
        let animation = try #require(PetAnimation(frames: ["first", "second"], frameDurationMs: 250))
        let policy = PetPlaybackPolicy(animation: animation, isVisible: true,
                                       isSleeping: true, reduceMotion: false)

        #expect(!policy.shouldAnimate)
        for elapsed in [0.0, 0.25, 0.75, 100.25] {
            #expect(policy.frame(at: elapsed) == "first")
        }
    }

    @Test func reduceMotionRetainsFirstFrame() throws {
        let animation = try #require(PetAnimation(frames: ["first", "second"], frameDurationMs: 250))
        let policy = PetPlaybackPolicy(animation: animation, isVisible: true,
                                       isSleeping: false, reduceMotion: true)

        #expect(!policy.shouldAnimate)
        for elapsed in [0.0, 0.25, 0.75, 100.25] {
            #expect(policy.frame(at: elapsed) == "first")
        }
    }
}
