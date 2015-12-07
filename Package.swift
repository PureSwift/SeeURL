import PackageDescription

let package = Package(
    name: "cURLSwift",
    dependencies: [
        .Package(url: "https://github.com/PureSwift/SwiftFoundation.git", majorVersion: 1),
    ],
    targets: [
        Target(
            name: "UnitTests",
            dependencies: [.Target(name: "cURLSwift")]),
        Target(
            name: "cURLSwift")
    ]
)