// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AIUsageBarometer",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "AIUsageBarometer", path: "Sources/AIUsageBarometer")
    ]
)
