// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Modules",
    defaultLocalization: "ko",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(name: "AppService", targets: ["AppService"]),
        .library(name: "AppData", targets: ["AppData"]),
        .library(name: "AppUI", targets: ["AppUI"]),
        .library(name: "APIInfra", targets: ["APIInfra"]),
        .library(name: "APITypes", targets: ["APITypes"]),
        .library(name: "APIClient", targets: ["APIClient"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-runtime.git", from: "1.9.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-generator.git", from: "1.10.3")
    ],
    targets: [
        .target(
            name: "APITypes",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
            ],
            plugins: [
                .plugin(
                    name: "OpenAPIGenerator",
                    package: "swift-openapi-generator"
                )
            ]
        ),
        .target(
            name: "APIClient",
            dependencies: [
                "APITypes",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "HTTPTypes", package: "swift-http-types")
            ],
            plugins: [
                .plugin(
                    name: "OpenAPIGenerator",
                    package: "swift-openapi-generator"
                )
            ]
        ),
        .target(
            name: "APIInfra",
            dependencies: [
                "APIClient",
                "APITypes",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                .product(name: "HTTPTypes", package: "swift-http-types")
            ]
        ),
        .target(
            name: "AppData",
            dependencies: [
                "AppService",
                "APIInfra"
            ]
        ),
        .target(
            name: "AppService",
            dependencies: []
        ),
        .target(
            name: "AppUI",
            dependencies: [
                "AppService",
                "AppData"
            ]
        )
    ]
)
