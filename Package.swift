// swift-tools-version: 6.1
// This is a Skip (https://skip.dev) package.
import PackageDescription

let package = Package(
    name: "kourt-app",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Kourt", type: .dynamic, targets: ["Kourt"]),
        .library(name: "KourtShared", targets: ["KourtShared"])
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.7.2"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0")
    ],
    targets: [
        .target(name: "Kourt", dependencies: [
            .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
            .product(name: "Algorithms", package: "swift-algorithms"),
            "KourtShared"
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
        .target(name: "KourtShared", dependencies: [])
    ]
)
