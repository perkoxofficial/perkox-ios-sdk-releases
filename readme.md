# Perkox Offerwall SDK for iOS

A lightweight iOS SDK for integrating the Perkox Offerwall into your iOS application. Allow your users to earn rewards by completing offers, surveys, and other engagement activities.

---

## Requirements

| Requirement | Version |
|---|---|
| iOS Deployment Target | 13.0+ |
| Swift | 5.7+ |
| Xcode | 14.0+ |
| Architectures | arm64 (device), arm64 + x86_64 (simulator) |

---

## Installation

### Option 1: Swift Package Manager via Git (Recommended)

1. Open your project in Xcode.
2. Go to **File → Add Package Dependencies…**
3. Enter the repository URL:
   ```
   https://github.com/perkoxofficial/perkox-ios-sdk-releases.git
   ```
4. Set the dependency rule to **Up to Next Major Version** (e.g. `2.0.1`) and click **Add Package**.

---

### Option 2: Direct Local XCFramework / Download

1. Download the latest release from the [GitHub Releases](https://github.com/perkoxofficial/perkox-ios-sdk-releases/releases) page.
2. Drag `PerkoxOfferwall.xcframework` directly into your Xcode project under **Frameworks, Libraries, and Embedded Content**.
3. Ensure **"Embed & Sign"** is selected.

```
perkox-ios-sdk-releases/
├── Package.swift
└── PerkoxOfferwall.xcframework/
    ├── Info.plist
    ├── ios-arm64/
    │   └── PerkoxOfferwall.framework/
    └── ios-arm64_x86_64-simulator/
        └── PerkoxOfferwall.framework/
```

---

## Quick Start

```swift
import UIKit
import PerkoxOfferwall

class ViewController: UIViewController {

    private func showOfferwall() {
        let offerwall = PerkoxOfferwall.create(
            appId: "YOUR_APP_ID",       // Your App ID
            sdkKey: "YOUR_SDK_KEY",     // Your SDK Key
            playerId: "Player_123"      // Unique player id
        )

        offerwall.launch(viewController: self)
    }
}
```

---

## API Reference

### PerkoxOfferwall

The main entry point for the SDK.

| Method | Parameters | Returns | Description |
|---|---|---|---|
| `create()` | `appId: String, sdkKey: String, playerId: String, beta: Bool = false` | `Offerwall` | Creates a new Offerwall instance. |
| `syncPendingRewards()` | `appId: String, sdkKey: String, playerId: String, beta: Bool = false, callback: (([[String: Any?]]) -> Void)?` | `Void` | Synchronizes pending rewards completed while the app was closed. |

### Offerwall

| Method / Property | Type | Description |
|---|---|---|
| `launch(viewController:)` | `UIViewController` | Presents the offerwall modally and automatically syncs pending rewards. |
| `onReward` | `(([String: Any?]) -> Void)?` | Callback triggered when a reward is received (supports all dynamic server fields). |
| `onClose` | `(() -> Void)?` | Callback triggered when the offerwall is closed. |

---

### ⚡ Offline & Pending Rewards Auto-Sync

When users complete offers (game milestones, surveys, etc.) outside of your application while your app is in the background or closed, rewards are **never lost**:

1. **Automatic Sync on Launch:** Calling `offerwall.launch(viewController: self)` automatically triggers a background query to fetch any pending rewards, delivers them to `onReward` on the Main Thread, and acknowledges receipt.
2. **Explicit Background Sync:** You can also check for rewards on app startup or user login without presenting the offerwall:

```swift
PerkoxOfferwall.syncPendingRewards(
    appId: "YOUR_APP_ID",
    sdkKey: "YOUR_SDK_KEY",
    playerId: "Player_123"
) { rewards in
    for reward in rewards {
        let amount = reward["amount"] as? Double ?? 0
        let txid = reward["txid"] as? String ?? ""
        let offerName = reward["offer_name"] as? String ?? "Offer"
        print("Synced offline reward: \(amount) pts (TxID: \(txid), Offer: \(offerName))")
    }
}
```

---

## Listening to Events & Dynamic Reward Payloads

Server parameters (such as `click_id`, `cid`, `offer_id`, `sub1`..`sub5`, `payout`, `amount`, `status`) are **100% dynamically preserved** and accessible directly from the dictionary:

### Full Example with Callbacks

```swift
import UIKit
import PerkoxOfferwall

class ViewController: UIViewController {

    private func showOfferwall() {
        let offerwall = PerkoxOfferwall.create(
            appId: "YOUR_APP_ID",
            sdkKey: "YOUR_SDK_KEY",
            playerId: "Player_123"
        )

        // Handle rewards with all dynamic server parameters
        offerwall.onReward = { reward in
            DispatchQueue.main.async {
                let amount = reward["amount"] as? Double ?? 0
                let status = reward["status"] as? String ?? "approved"
                let txid = reward["txid"] as? String ?? ""
                let playerId = reward["player_id"] as? String ?? ""
                let clickId = reward["click_id"] as? String ?? ""
                let offerId = reward["offer_id"]

                print("Reward received! Amount: \(amount), TxID: \(txid), Offer: \(offerId ?? "")")
            }
        }

        // Handle close
        offerwall.onClose = {
            DispatchQueue.main.async {
                print("Offerwall closed")
            }
        }

        // Launch the offerwall
        offerwall.launch(viewController: self)
    }
}
```

### Reward Data Fields

| Field | Type | Description |
|---|---|---|
| `amount` / `payout` | `Double` / `NSNumber` | The reward amount or points |
| `txid` | `String` | Unique transaction identifier |
| `status` | `String` | `"approved"`, `"pending"`, `"reversed"`, `"rejected"` |
| `player_id` | `String` | Player identifier |
| `click_id` | `String` | The conversion click ID (dynamic) |
| `offer_id` | `Any?` | Offer ID (dynamic) |
| `offer_name` | `String?` | Name of the completed offer |
| `...custom` | `Any?` | Any custom advertiser/postback parameters preserved dynamically |

> **Anti-Duplicate Guarantee:** Claimed reward transaction IDs are automatically posted back to the server (`POST /rewards/claim`), guaranteeing idempotent delivery across restarts.

---

## Troubleshooting

**1. "No such module 'PerkoxOfferwall'" build error**
- Make sure you selected your app target when the "Add Package" prompt appeared
- Go to your target → **General** → **Frameworks, Libraries, and Embedded Content** and verify `PerkoxOfferwall` is listed
- Clean the build folder (**Product → Clean Build Folder** or `Cmd+Shift+K`) and rebuild

**2. Xcode can't find the local package after moving files**
- Xcode references local packages by absolute path — if you move the folder, the reference breaks
- Remove the package from the project (**File → Packages → Reset Package Caches**), then re-add it from the new location

**3. Offerwall not loading content**
- Verify your `appId` and `sdkKey` are correct
- Check internet connectivity
- Ensure the `playerId` is not empty

---

## Changelog

### v2.0.1
- Fix Apple Privacy Manifest (`PrivacyInfo.xcprivacy`) Required Reason API category (`NSPrivacyAccessedAPICategoryUserDefaults` with code `CA92.1`) for App Store submission compliance (ITMS-91054).

### v2.0.0
- Add IDFA, IDFV, and App Tracking Transparency (ATT) signals.
- Full device, network, and security anti-fraud signal injection.

### v1.0.0
- Initial release
- Seamless offerwall integration via Swift Package

---

## Support

For questions, issues, or feature requests: [support@perkox.com](mailto:support@perkox.com)
