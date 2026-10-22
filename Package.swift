// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NotchPet",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "NotchPet", targets: ["NotchPet"])
    ],
    targets: [
        .executableTarget(name: "NotchPet")
    ]
)
