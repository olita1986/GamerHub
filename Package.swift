// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "GamerHub",
    products: [
        .library(name: "GamerHub", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

//        // Mongo Kitten
//        .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "5.0.0"),

        // Meow Vapor
        .package(url: "https://github.com/OpenKitten/MeowVapor.git", from: "2.0.0"),

        // JWT
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),

    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "MeowVapor", "JWT"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

