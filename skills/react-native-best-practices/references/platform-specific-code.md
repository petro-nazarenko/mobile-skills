# Platform-Specific Code Reference

## Platform.OS

```tsx
import { Platform } from 'react-native';

// Values: 'ios' | 'android' | 'web' | 'windows' | 'macos'
if (Platform.OS === 'ios') {
  // iOS-only logic
}

if (Platform.OS === 'android') {
  // Android-only logic
}
```

## Platform.select() Pattern

Preferred over if/else for style objects and config:

```tsx
import { Platform, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  container: {
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.25,
        shadowRadius: 4,
      },
      android: {
        elevation: 4,
      },
      default: {
        // web or other platforms
        boxShadow: '0 2px 4px rgba(0,0,0,0.25)',
      },
    }),
  },
});

// Also works for values, not just style objects
const hitSlop = Platform.select({ ios: 10, android: 8, default: 10 });
```

## File Extensions: .ios.tsx / .android.tsx

Metro auto-resolves platform-specific files:

```
Button.tsx          ← default (both platforms)
Button.ios.tsx      ← iOS override
Button.android.tsx  ← Android override
Button.native.tsx   ← native (ios + android, not web)
Button.web.tsx      ← web only
```

**When to use split files vs Platform.select:**

| Use split files when | Use Platform.select when |
|---------------------|------------------------|
| Entire component differs | Small style/value differences |
| Different import dependencies | Same imports, different props |
| Significantly different UX | Minor behavioral tweaks |
| Native module differences | Logic is mostly shared |

```tsx
// Button.ios.tsx
export const Button = () => <TouchableOpacity style={iosStyles} />;

// Button.android.tsx
export const Button = () => <TouchableNativeFeedback style={androidStyles} />;

// Usage (Metro picks the right file automatically)
import { Button } from './Button';
```

## Platform.Version for Conditional APIs

```tsx
import { Platform } from 'react-native';

// iOS: string like "16.0"
// Android: integer like 33 (API level)
if (Platform.OS === 'android' && Platform.Version >= 33) {
  // Android 13+ (API 33) — request granular media permissions
}

if (Platform.OS === 'ios') {
  const majorVersion = parseInt(Platform.Version as string, 10);
  if (majorVersion >= 16) {
    // iOS 16+ features
  }
}
```

## Audit Checklist

### Shadow vs Elevation
```tsx
// WRONG — shadow props ignored on Android, elevation ignored on iOS
const style = {
  shadowColor: '#000',   // iOS only
  shadowOffset: { width: 0, height: 2 },  // iOS only
  shadowOpacity: 0.3,   // iOS only
  shadowRadius: 4,      // iOS only
  elevation: 4,         // Android only
};

// CORRECT — use Platform.select or a shared shadow utility
const shadow = Platform.select({
  ios: { shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.3, shadowRadius: 4 },
  android: { elevation: 4 },
});
```

### StatusBar
```tsx
import { StatusBar, Platform } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

// Android: StatusBar overlaps content by default
// iOS: notch/Dynamic Island handled by SafeAreaView

const App = () => (
  <SafeAreaView style={{ flex: 1 }}>
    <StatusBar
      barStyle={Platform.OS === 'ios' ? 'dark-content' : 'light-content'}
      backgroundColor={Platform.OS === 'android' ? '#ffffff' : undefined}
    />
    {/* content */}
  </SafeAreaView>
);
```

### SafeAreaView
```bash
npm install react-native-safe-area-context
```

```tsx
// WRONG — built-in SafeAreaView only works on iOS
import { SafeAreaView } from 'react-native';

// CORRECT — works on iOS and Android (including gesture bar)
import { SafeAreaView, SafeAreaProvider } from 'react-native-safe-area-context';

// Wrap app root
<SafeAreaProvider>
  <App />
</SafeAreaProvider>

// Use edges to control which sides get padding
<SafeAreaView edges={['top', 'bottom']}>
  {/* content */}
</SafeAreaView>
```

## Common Pitfall: Hardcoded Pixel Values

```tsx
import { PixelRatio, Dimensions } from 'react-native';

// WRONG — looks different on high-density screens
const style = { borderWidth: 1, fontSize: 14 };

// CORRECT — use PixelRatio for hairline borders
const hairline = StyleSheet.hairlineWidth;  // thinnest possible line

// Scale font sizes
const scale = PixelRatio.getFontScale();
const normalizedFont = (size: number) => size / scale;

// Screen dimensions (re-check on orientation change)
const { width, height } = Dimensions.get('window');

// Use useWindowDimensions hook for reactive dimensions
import { useWindowDimensions } from 'react-native';
const { width, height } = useWindowDimensions();
```

## Audit Commands

```bash
# Find all Platform.OS checks
grep -r 'Platform\.OS' src/ --include='*.tsx' --include='*.ts' -n

# Find platform split files
find . \( -name '*.ios.tsx' -o -name '*.android.tsx' -o -name '*.ios.ts' -o -name '*.android.ts' \) \
  ! -path '*/node_modules/*'

# Find hardcoded pixel values (potential issues)
grep -r 'borderWidth: [2-9]' src/ --include='*.tsx' -n
grep -r 'shadowColor' src/ --include='*.tsx' -n  # check paired with elevation

# Find missing elevation counterparts
grep -r 'shadowColor' src/ --include='*.tsx' -l | xargs grep -L 'elevation'
```
