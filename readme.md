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

### Step 1: Download the SDK

Download the latest release zip from the [GitHub Releases](https://github.com/perkoxofficial/perkox-ios-sdk-releases/releases) page. Extract the zip anywhere you like — you will get a folder named `perkox-ios-sdk-release-{version}` containing a `Package.swift` and the bundled `PerkoxOfferwall.xcframework`.

```
perkox-ios-sdk-release-{version}/
├── Package.swift
└── PerkoxOfferwall.xcframework/
    ├── Info.plist
    ├── ios-arm64/
    │   └── PerkoxOfferwall.framework/
    └── ios-arm64_x86_64-simulator/
        └── PerkoxOfferwall.framework/
```

### Step 2: Add the Package to Your Xcode Project

In Xcode, add the SDK as a local Swift Package:

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies…**
3. In the bottom-left of the dialog, click **"Add Local…"**
4. Navigate to and select the extracted `perkox-ios-sdk-release-{version}` folder
5. Click **"Add Package"**
6. In the next prompt, make sure your app target is checked, then click **"Add Package"** again

> **Tip:** Place the extracted folder somewhere stable (e.g. next to your `.xcodeproj` file) before adding it, as Xcode references it by path.

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
| `create()` | `appId: String, sdkKey: String, playerId: String` | `Offerwall` | Creates a new Offerwall instance |

### Offerwall

| Method / Property | Type | Description |
|---|---|---|
| `launch(viewController:)` | `UIViewController` | Presents the offerwall modally from the given view controller |
| `onReward` | `(([String: Any?]) -> Void)?` | Callback triggered when a reward is received |
| `onClose` | `(() -> Void)?` | Callback triggered when the offerwall is closed |

---

## Listening to Events

You can listen to reward and close events by setting callbacks before launching the offerwall.

> ⚠️ **Important:** Do **not** rely on the SDK's reward callbacks to grant rewards to users, as these callbacks only work when the offerwall is launched. Instead, use the postback URL you provided to Perkox to handle rewards on your server, or distribute the reward data using **webhooks** or similar server-side technologies for accurate and reliable reward processing.

> **Note:** The `onReward` callback may be called multiple times for the same transaction with different statuses.

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

        // Handle rewards
        offerwall.onReward = { reward in
            DispatchQueue.main.async {
                let amount = reward["amount"] as? Double ?? 0
                let status = reward["status"] as? String ?? "?"
                let txid = reward["txid"] as? String ?? "?"
                let playerId = reward["player_id"] as? String ?? "?"
                print("Reward received! Amount: \(amount), Status: \(status)")
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
| `amount` | `Double` | The reward amount |
| `txid` | `String` | Unique transaction ID |
| `status` | `String` | `"pending"` \| `"approved"` \| `"rejected"` \| `"reversed"` |
| `player_id` | `String` | Player ID |

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

### v1.0.0
- Initial release
- Seamless offerwall integration via Swift Package

---

## Support

For questions, issues, or feature requests: [support@perkox.com](mailto:support@perkox.com)
