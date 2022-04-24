// swift-tools-version: 5.5

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "One Step Ahead",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "One Step Ahead",
            targets: ["AppModule"],
            bundleIdentifier: "Ethan-Marshall.One-Step-Ahead",
            teamIdentifier: "GUDZ7ALN9J",
            displayVersion: "1.0",
            bundleVersion: "1",
            iconAssetName: "AppIcon",
            accentColorAssetName: "AccentColor",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .landscapeRight,
                .landscapeLeft
            ],
            additionalInfoPlistContentFilePath: "ConfigList.plist"
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            exclude: [
                "./ConfigList.plist",
                "./README.md"
            ],
            resources: [
                .process("Music & Sound Effects"),
                .process("Helper Files/Drawing Judge Files/Drawing Judge.mlmodelc"),
                .process("Helper Files/SpriteKit UI Helpers")
            ]
        )
    ]
)
