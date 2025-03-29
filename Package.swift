// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "NetworkingExtensions",
	platforms: [
		.iOS        (.v15),
		.macCatalyst(.v15),
		.macOS      (.v12),
		.tvOS       (.v15),
		.visionOS   (.v1),
		.watchOS    (.v8),
	],
	products: [
		// Products define the executables and libraries a package produces, making them visible to other packages.
		.library(
			name:     "NetworkingExtensions",
			targets: ["NetworkingExtensions"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-http-types", from: "1.0.0"),
	],
	targets: [
		// Targets are the basic building blocks of a package, defining a module or a test suite.
		// Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "NetworkingExtensions",
			dependencies: [
				.product(name: "HTTPTypes", package: "swift-http-types")
			],
			swiftSettings: [
				.enableUpcomingFeature("ExistentialAny"),
			]
		),
	]
)
