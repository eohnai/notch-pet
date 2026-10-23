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
        .executableTarget(name: "NotchPet", dependencies: ["EventBridge"]),
        .executableTarget(name: "NotchPetHook", dependencies: ["EventBridge"]),
        .testTarget(name: "EventBridgeTests", dependencies: ["EventBridge"])
    ]
)
