import Foundation

public struct PetPreferences {
    public static let defaultSize = 120.0
    public static let sizeRange = 64.0...256.0
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var size: Double {
        get {
            guard let value = defaults.object(forKey: "pet.size") as? Double,
                  value.isFinite, Self.sizeRange.contains(value) else { return Self.defaultSize }
            return value
        }
        set {
            let safe = newValue.isFinite && Self.sizeRange.contains(newValue) ? newValue : Self.defaultSize
            defaults.set(safe, forKey: "pet.size")
        }
    }
}
