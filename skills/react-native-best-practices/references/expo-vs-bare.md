# Expo vs Bare Workflow Reference

## Decision Matrix

| Scenario | Recommended Workflow |
|----------|---------------------|
| Prototype / MVP | Expo Go (fastest start) |
| Standard app, no custom native | Expo Managed |
| Need specific native module | Expo Bare (via prebuild) |
| Full native control | Bare React Native |
| Team has no iOS/Android experience | Expo Managed + EAS Build |
| Existing native codebase | Bare React Native |
| OTA updates required | Expo (expo-updates) |
| App Store distribution | EAS Build (any workflow) |

## The Spectrum

```
Expo Go → Expo Managed → Expo Bare → Bare React Native
  ↑ easier                              harder ↑
  ↑ less control                    full control ↑
```

### Expo Go
- No build step — scan QR code
- Limited to Expo SDK modules only
- Cannot use custom native code
- Good for: learning, demos, proof of concept

### Expo Managed
- `npx create-expo-app`
- Uses app.json / app.config.js for all config
- CNG: Expo generates native folders on build
- Cannot commit ios/ android/ (they're generated)
- Add native functionality via config plugins

### Expo Bare
- `npx expo prebuild` generates ios/ and android/
- Commit native folders, customize freely
- Still uses expo-modules-core
- Best of both worlds for most production apps

### Bare React Native
- `npx react-native init`
- Full control, no Expo overhead
- Manual native module linking
- Best for: teams with native expertise

## expo-modules-core for Native Modules in Bare

```bash
# In bare workflow, add Expo modules support
npx install-expo-modules
```

```tsx
// Write custom native module using Expo Modules API
// ios/MyModule/MyModuleModule.swift
import ExpoModulesCore

public class MyModuleModule: Module {
  public func definition() -> ModuleDefinition {
    Name("MyModule")
    Function("getValue") { return "Hello from native!" }
  }
}
```

## EAS Build vs Local Xcode/Gradle

| | EAS Build | Local Build |
|--|-----------|-------------|
| Requires Mac for iOS | No | Yes |
| Build speed | Cloud parallel | Local machine |
| Cost | Free tier + paid | Free |
| Secrets management | EAS Secrets | Local keystore |
| CI/CD integration | Built-in | Manual |
| Debug builds | Yes (dev client) | Yes |

```bash
# Install EAS CLI
npm install -g eas-cli

# Configure
eas build:configure

# Build for testing
eas build --platform android --profile preview

# Build for store
eas build --platform all --profile production

# Submit to stores
eas submit --platform ios
eas submit --platform android
```

## When Managed Workflow Breaks (Native Code Needed)

Signs you need to eject/prebuild:
- Third-party SDK requires custom native setup (e.g., Stripe, Braintree)
- Need background audio/location with custom native config
- Require a React Native library not in Expo SDK
- Custom push notification handling
- Deep Bluetooth/NFC/hardware access

**Solution: Use a config plugin first before ejecting**

```js
// app.config.js — config plugin approach
export default {
  expo: {
    plugins: [
      ['expo-camera', { cameraPermission: 'Allow $(PRODUCT_NAME) to access your camera.' }],
      ['./plugins/withCustomNativeCode', { option: true }],
    ],
  },
};
```

## CNG — Continuous Native Generation

With CNG, native folders are generated artifacts (don't commit them):

```gitignore
# .gitignore for Expo managed/CNG
ios/
android/
```

```bash
# Regenerate native folders
npx expo prebuild --clean

# Prebuild for specific platform
npx expo prebuild --platform ios
```

## Migration: Managed → Bare (expo prebuild)

```bash
# Step 1: Run prebuild (generates ios/ and android/)
npx expo prebuild

# Step 2: Verify native projects build
cd ios && pod install && cd ..
npx expo run:ios
npx expo run:android

# Step 3: Commit native folders
git add ios/ android/
git commit -m 'chore: eject to bare workflow via expo prebuild'

# Step 4: Update CI/CD to run pod install
```

**What changes after prebuild:**
- You own ios/ and android/ — update them manually
- Config plugins still run during `expo prebuild`
- app.json still controls some config via plugins
- Must run `npx expo prebuild` after adding new native modules

## OTA Updates: expo-updates vs CodePush

| | expo-updates | CodePush (AppCenter) |
|--|-------------|---------------------|
| Maintained | Yes (Expo) | Being deprecated |
| Expo integration | Native | Third-party |
| EAS Update | Yes | No |
| Self-hosted | Yes (OSS) | Paid |
| Bundle delta | Yes | Yes |

```bash
# expo-updates setup
npx expo install expo-updates

# Publish OTA update
eas update --branch production --message "Fix login bug"

# In app: check for update on launch
import * as Updates from 'expo-updates';

async function checkForUpdate() {
  const update = await Updates.checkForUpdateAsync();
  if (update.isAvailable) {
    await Updates.fetchUpdateAsync();
    await Updates.reloadAsync();
  }
}
```
