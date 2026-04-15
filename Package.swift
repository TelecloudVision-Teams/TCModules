// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TCModules",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "TCSharedFramework", targets: ["TCSharedFramework"]),
        .library(name: "TCPaymentValidation", targets: ["TCPaymentValidation"]),
        .library(name: "TCPayment", targets: ["TCPayment"]),
        .library(name: "TCAnalytics", targets: ["TCAnalytics"])
    ],
    dependencies: [
        .package(url: "https://github.com/TelecloudVision-Teams/TCNetwork.git", from: "1.1.1"),
        .package(url: "https://github.com/TelecloudVision-Teams/LocationFramework.git", from: "1.0.16"),
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "20.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
        .package(url: "https://github.com/BranchMetrics/ios-branch-deep-linking-attribution.git", from: "3.4.3"),
        .package(url: "https://github.com/stripe/stripe-ios-spm.git", from: "24.0.0"),
        .package(url: "https://github.com/parse-community/Parse-SDK-iOS-OSX.git", exact: "5.1.1")
    ],
    targets: [
        .target(
            name: "TCSharedFramework",
            path: "Sources/SharedFramework"
        ),

        .target(
            name: "TCPaymentValidation",
            dependencies: [
                .product(name: "ParseObjC", package: "Parse-SDK-iOS-OSX")
            ],
            path: "Sources/TCPaymentValidation"
        ),

        .target(
            name: "TCPayment",
            dependencies: [
                "TCSharedFramework",
                "TCPaymentValidation",
                .product(name: "Stripe", package: "stripe-ios-spm"),
                .product(name: "StripePaymentSheet", package: "stripe-ios-spm")
            ],
            path: "Sources/TCPayment"
        ),

        .target(
            name: "TCAnalytics",
            dependencies: [
                "TCSharedFramework",
                .product(name: "TCNetwork", package: "TCNetwork"),
                .product(name: "TCLocationFramework", package: "LocationFramework"),
                .product(name: "KeychainSwift", package: "keychain-swift"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "BranchSDK", package: "ios-branch-deep-linking-attribution")
            ],
            path: "Sources/TCAnalyticsFramework"
        ),

        .testTarget(
            name: "TCSharedFrameworkTests",
            dependencies: ["TCSharedFramework"],
            path: "Tests/SharedFrameworkTests"
        ),

        .testTarget(
            name: "TCPaymentTests",
            dependencies: ["TCPayment"],
            path: "Tests/TCPaymentTests"
        ),

        .testTarget(
            name: "TCAnalyticsFrameworkTests",
            dependencies: ["TCAnalytics"],
            path: "Tests/TCAnalyticsFrameworkTests"
        )
    ]
)
