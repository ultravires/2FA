// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "2FA",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "2FA", targets: ["2FA"]),
    ],
    dependencies: [
        .package(url: "https://github.com/lachlanbell/SwiftOTP", from: "3.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "2FA",
            dependencies: [
                "SwiftOTP"
            ],
            path: "2FA"
        )
    ]
)
