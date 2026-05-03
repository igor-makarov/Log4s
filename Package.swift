// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Log4swift",
    platforms: [
        .iOS(.v12), .macOS(.v10_13), .watchOS(.v4)
    ],
    products: [
        .library(name: "Log4swift", targets: ["Log4swift"])
    ],
    // Test targets are macOS-only (XCTest bundles under SwiftPM only run on
    // the host). iOS/watchOS test coverage still goes through xcodebuild on
    // the SwiftPM package via `xcodebuild -scheme Log4swift`.

    targets: [
        // Pure-Swift module.
        .target(
            name: "Log4swift",
            path: "Log4swift",
            exclude: [
                "log4swift.h"
            ],
            sources: [
                "Appenders",
                "Formatters",
                "RotationPolicy",
                "Utilities",
                "Errors.swift",
                "Logger.swift",
                "Logger+convenience.swift",
                "Logger+objectiveC.swift",
                "LoggerFactory.swift",
                "LoggerFactory+loadFromFile.swift",
                "LogInformation.swift",
                "LogLevel.swift"
            ]
        ),

        .testTarget(
            name: "Log4swiftTests",
            dependencies: ["Log4swift"],
            path: "Log4swiftTests",
            resources: [
                .copy("Resources/ValidCompleteConfiguration.plist")
            ]
        )

        // NOTE: Log4swiftPerformanceTests/ is not wired up: it has pre-existing
        // compile errors (calls to FileAppender initialisers that no longer
        // exist — `maxFileAge:`, `maxFileSize:` — and it relies on
        // `createTemporaryFilePath` which under the old xcodeproj was shared
        // from Log4swiftTests via Xcode file-membership, a mechanism SwiftPM
        // does not have. Fix the API references and share the helper (e.g.
        // move it into the Log4swift module under an internal test hook) if
        // you want to bring these tests back.
    ],
    swiftLanguageVersions: [.v5]
)
