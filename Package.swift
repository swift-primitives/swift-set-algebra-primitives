// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-set-algebra-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        // MARK: - Algebra
        .library(
            name: "Set Algebra Primitives",
            targets: ["Set Algebra Primitives"]
        ),

        // MARK: - Test Support
        .library(
            name: "Set Algebra Primitives Test Support",
            targets: ["Set Algebra Primitives Test Support"]
        ),
    ],
    dependencies: [
        // The membership core (Set.Protocol) lives in swift-set-primitives; the
        // build capability (Buildable: Initiable + add) in swift-builder-primitives;
        // the iteration concern (Iterable) in swift-iterator-primitives. This
        // package bridges them with the orthogonal element-wise algebra: predicates
        // over Set.Protocol × Iterable, constructive/powerset over Set.Protocol ×
        // Buildable × Iterable. There is NO bundled Set.Buildable.Protocol — the
        // buildable concern is builder-primitives × set-primitives. It deps DOWN
        // onto all three; swift-set-primitives deps this package NOWHERE ([MOD-032]).
        .package(url: "https://github.com/swift-primitives/swift-set-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-builder-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-iterator-primitives.git", branch: "main"),
        // The formal algebra substrate grounds the set ops as ∪ = join / ∩ = meet
        // over a packaged bounded lattice (model §4.2 / §9). The complement
        // (∁A = U ∖ A) is this package's own native `subtracting`; there is no
        // Boolean-algebra witness type — `Swift.Bool` is the canonical Boolean
        // algebra (swift-bool-algebra-primitives), separate from this. Downward dep:
        .package(url: "https://github.com/swift-primitives/swift-algebra-primitives.git", branch: "main"),
    ],
    targets: [

        // MARK: - Algebra (predicates `where Self: Set.Protocol & Iterable` +
        // constructive `where Self: Set.Protocol & Buildable & Iterable` → Self;
        // lifted from swift-set-primitives, [MOD-014] Form-1 extraction)
        .target(
            name: "Set Algebra Primitives",
            dependencies: [
                .product(name: "Set Protocol Primitives", package: "swift-set-primitives"),
                .product(name: "Builder Primitives", package: "swift-builder-primitives"),
                .product(name: "Iterable", package: "swift-iterator-primitives"),
                .product(name: "Algebra Lattice Primitives", package: "swift-algebra-primitives"),
            ]
        ),

        // MARK: - Test Support (the Set.Protocol × Iterable × Buildable conformer fixture)
        .target(
            name: "Set Algebra Primitives Test Support",
            dependencies: [
                "Set Algebra Primitives",
                // TS-of-dep ([MOD-024]): surfaces Iterator.Chunk for the
                // fixture's Iterable conformance.
                .product(name: "Iterator Primitives Test Support", package: "swift-iterator-primitives"),
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "Set Algebra Primitives Tests",
            dependencies: [
                "Set Algebra Primitives",
                "Set Algebra Primitives Test Support",
            ],
            path: "Tests/Set Algebra Primitives Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
