import Foundation
import Testing
@testable import Pet

struct PetPreferencesTests {
    @Test func missingSizeUsesUsableDefault() throws {
        let suite = "local.notchpet.tests." + UUID().uuidString
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        #expect(PetPreferences(defaults: defaults).size == 120)
    }

    @Test func invalidStoredSizeUsesDefault() throws {
        let suite = "local.notchpet.tests." + UUID().uuidString
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        for value: Any in ["large", true, Double.nan, Double.infinity, -1.0, 0.0, 63.0, 257.0] {
            defaults.set(value, forKey: "pet.size")
            #expect(PetPreferences(defaults: defaults).size == 120)
        }
    }

    @Test func savedSizeRestoresInNewPreferencesInstance() throws {
        let suite = "local.notchpet.tests." + UUID().uuidString
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        var preferences = PetPreferences(defaults: defaults)
        preferences.size = 180
        let restored = PetPreferences(defaults: try #require(UserDefaults(suiteName: suite)))
        #expect(restored.size == 180)
    }

    @Test func preferencesPersistOnlySizeAndValidateWrites() throws {
        let suite = "local.notchpet.tests." + UUID().uuidString
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        var preferences = PetPreferences(defaults: defaults)
        for size in [64.0, 120.0, 256.0] {
            preferences.size = size
            #expect(preferences.size == size)
        }
        preferences.size = .infinity
        #expect(preferences.size == 120)
        #expect(Set(defaults.persistentDomain(forName: suite)?.keys.map { $0 } ?? []) == ["pet.size"])
    }
}
