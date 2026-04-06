// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PerkoxOfferwall",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "PerkoxOfferwall", targets: ["PerkoxOfferwall"])
    ],
    targets: [
        .binaryTarget(
            name: "PerkoxOfferwall",
            path: "PerkoxOfferwall.xcframework"
        )
    ]
)