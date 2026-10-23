// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NotchPet",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "NotchPet", targets: ["NotchPet"]),
        .executable(name: "NotchPetHook", targets: ["NotchPetHook"])
    ],
    targets: [
        .target(name: "EventBridge"),
        .target(name: "SessionState", dependencies: ["EventBridge"]),
        .executableTarget(name: "NotchPet", dependencies: ["EventBridge", "SessionState"]),
        .executableTarget(name: "NotchPetHook", dependencies: ["EventBridge"]),
        .testTarget(name: "EventBridgeTests", dependencies: ["EventBridge"]),
        .testTarget(name: "SessionStateTests", dependencies: ["SessionState", "EventBridge"])
    ]
)
