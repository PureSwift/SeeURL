import PackageDescription

let package = Package(
    name: "SeeURL",
    dependencies: [
        .Package(url: "https://github.com/PureSwift/SwiftFoundation.git", majorVersion: 1),
        .Package(url: "https://github.com/PureSwift/CcURL.git", majorVersion: 1)
    ],
    targets: [
        Target(
            name: "UnitTests",
            dependencies: [.Target(name: "SeeURL")]),
        Target(
            name: "SeeURL")
    ]
)