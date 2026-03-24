// swift-tools-version: 6.0
//
//  Package.swift
//  ARCPurchasing
//
//  Created by ARC Labs Studio on 23/01/2025.
//

import PackageDescription

let package = Package(name: "ARCPurchasing",

                      platforms: [.iOS(.v17),
                                  .macOS(.v14),
                                  .watchOS(.v10),
                                  .tvOS(.v17),
                                  .visionOS(.v1)],

                      products: [.library(name: "ARCPurchasing",
                                          targets: ["ARCPurchasing"]),
                                 .library(name: "ARCPurchasingUI",
                                          targets: ["ARCPurchasingUI"])],

                      dependencies: [// RevenueCat SDK
                          .package(url: "https://github.com/RevenueCat/purchases-ios",
                                   from: "5.0.0"),
                          // ARC Labs packages
                          .package(url: "https://github.com/arclabs-studio/ARCLogger",
                                   from: "1.0.0")],

                      targets: [.target(name: "ARCPurchasing",
                                        dependencies: [.product(name: "RevenueCat", package: "purchases-ios"),
                                                       .product(name: "ARCLogger", package: "ARCLogger")],
                                        path: "Sources/ARCPurchasing",
                                        swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]),
                                .testTarget(name: "ARCPurchasingTests",
                                            dependencies: ["ARCPurchasing",
                                                           .product(name: "RevenueCat", package: "purchases-ios")],
                                            path: "Tests/ARCPurchasingTests"),
                                .target(name: "ARCPurchasingUI",
                                        dependencies: ["ARCPurchasing",
                                                       .product(name: "RevenueCat", package: "purchases-ios"),
                                                       .product(name: "RevenueCatUI",
                                                                package: "purchases-ios")],
                                        path: "Sources/ARCPurchasingUI",
                                        swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]),
                                .testTarget(name: "ARCPurchasingUITests",
                                            dependencies: ["ARCPurchasingUI"],
                                            path: "Tests/ARCPurchasingUITests")],

                      swiftLanguageModes: [.v6])
