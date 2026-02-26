// swift-tools-version: 6.1
// This is a Skip (https://skip.dev) package.
import PackageDescription

let package = Package(
    name: "kourt-app",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Kourt", type: .dynamic, targets: ["Kourt"]),
        .library(name: "KourtShared", targets: ["KourtShared"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.7.2"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/maiyama18/LicensesPlugin.git", from: "0.2.0"),
    ],
    targets: [
        .target(
            name: "Kourt",
            dependencies: [
                .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
                "KourtShared",
            ], resources: [.process("Resources")],
            plugins: [
                .plugin(name: "skipstone", package: "skip"),
                .plugin(name: "LicensesPlugin", package: "LicensesPlugin"),
            ],
        ),
        .target(
            name: "KourtShared",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
        ),
        .testTarget(name: "KourtSharedTests", dependencies: ["KourtShared"]),
    ],
)
