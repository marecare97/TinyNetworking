// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TinyNetworking",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "TinyNetworking",
            targets: ["TinyNetworking"]
        ),
        .library(
            name: "RxTinyNetworking",
            targets: ["RxTinyNetworking"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(
            name: "TinyNetworking",
            dependencies: [],
            path: "Sources/TinyNetworking" // Ensure this matches your directory structure
        ),
        .target(
            name: "RxTinyNetworking",
            dependencies: ["TinyNetworking", "RxSwift"],
            path: "Sources/RxTinyNetworking" // Ensure this matches your directory structure
        )
    ]
)
