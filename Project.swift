import ProjectDescription

let project = Project(
    name: "VidSave",
    targets: [
        .target(
            name: "VidSave",
            destinations: .iOS,
            product: .app,
            bundleId: "com.privat.vidsave",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "NSPhotoLibraryAddUsageDescription":
                    .string("VidSave speichert Videos in deiner Galerie."),
                "NSAppTransportSecurity": .dictionary([
                    "NSAllowsArbitraryLoads": .boolean(true)
                ]),
                "UILaunchScreen": .dictionary([:])
            ]),
            sources: ["VidSave/**/*.swift"]
        )
    ]
)