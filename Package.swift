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
                                          targets: ["ARCPurchasingUI"]),
                                 .library(name: "ARCPurchasingRevenueCat",
                                          targets: ["ARCPurchasingRevenueCat"]),
                                 .library(name: "ARCPurchasingRevenueCatUI",
                                          targets: ["ARCPurchasingRevenueCatUI"])],

                      dependencies: [// RevenueCat SDK
                          .package(url: "https://github.com/RevenueCat/purchases-ios",
                                   from: "5.0.0"),
                          // ARC Labs packages
                          .package(url: "https://github.com/arclabs-studio/ARCLogger",
                                   from: "1.0.0")],

                      targets: [// Core — provider-agnostic, zero RevenueCat dependency
                          .target(name: "ARCPurchasing",
                                  dependencies: [.product(name: "ARCLogger", package: "ARCLogger")],
                                  path: "Sources/ARCPurchasing",
                                  swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]),
                          .testTarget(name: "ARCPurchasingTests",
                                      dependencies: ["ARCPurchasing"],
                                      path: "Tests/ARCPurchasingTests"),

                          // Custom paywall UI — provider-agnostic
                          .target(name: "ARCPurchasingUI",
                                  dependencies: ["ARCPurchasing"],
                                  path: "Sources/ARCPurchasingUI",
                                  swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]),
                          .testTarget(name: "ARCPurchasingUITests",
                                      dependencies: ["ARCPurchasingUI"],
                                      path: "Tests/ARCPurchasingUITests"),

                          // RevenueCat provider
                          .target(name: "ARCPurchasingRevenueCat",
                                  dependencies: ["ARCPurchasing",
                                                 .product(name: "RevenueCat",
                                                          package: "purchases-ios"),
                                                 .product(name: "ARCLogger",
                                                          package: "ARCLogger")],
                                  path: "Sources/ARCPurchasingRevenueCat",
                                  swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]),
                          .testTarget(name: "ARCPurchasingRevenueCatTests",
                                      dependencies: ["ARCPurchasingRevenueCat",
                                                     .product(name: "RevenueCat",
                                                              package: "purchases-ios")],
                                      path: "Tests/ARCPurchasingRevenueCatTests"),

                          // RevenueCat-specific UI (Customer Center)
                          .target(name: "ARCPurchasingRevenueCatUI",
                                  dependencies: ["ARCPurchasingRevenueCat",
                                                 .product(name: "RevenueCatUI",
                                                          package: "purchases-ios")],
                                  path: "Sources/ARCPurchasingRevenueCatUI",
                                  swiftSettings: [.enableUpcomingFeature("StrictConcurrency")])],

                      swiftLanguageModes: [.v6])
