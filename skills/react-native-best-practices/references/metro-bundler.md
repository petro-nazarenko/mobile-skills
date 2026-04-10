# Metro Bundler Reference

## metro.config.js — Core Configuration

```js
const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');

const config = {
  resolver: {
    // Add source extensions (e.g., for TypeScript, SVG)
    sourceExts: ['tsx', 'ts', 'jsx', 'js', 'json', 'svg'],
    // Asset extensions
    assetExts: ['png', 'jpg', 'gif', 'webp', 'ttf', 'otf', 'mp4'],
    // Monorepo: resolve symlinks
    unstable_enableSymlinks: true,
  },
  transformer: {
    // Enable Hermes (recommended for RN 0.70+)
    hermesParser: true,
    // Inline requires: lazily evaluate imports (speeds up startup)
    inlineRequires: true,
    // Custom transformer for SVGs
    babelTransformerPath: require.resolve('react-native-svg-transformer'),
  },
  // Watchman config for large repos
  watchFolders: [],
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
```

## RAM Bundles vs Hermes

| Feature | RAM Bundles | Hermes |
|---------|-------------|--------|
| Startup time | Good | Better |
| Memory | Moderate | Lower |
| Debugger | Chrome | Hermes Inspector |
| Android support | Yes | Yes (preferred) |
| iOS support | Yes | Yes (RN 0.64+) |

**Recommendation:** Use Hermes for all new projects (RN 0.70+). Enable in android/app/build.gradle:
```gradle
project.ext.react = [
    enableHermes: true
]
```
And in ios/Podfile:
```ruby
use_react_native!(:hermes_enabled => true)
```

## Bundle Splitting with @react-native-community/cli

```bash
# Measure bundle size
npx react-native bundle \
  --platform android \
  --dev false \
  --entry-file index.js \
  --bundle-output /tmp/bundle.js \
  --assets-dest /tmp/assets \
  --stats /tmp/stats.json

# Analyze bundle
npx source-map-explorer /tmp/bundle.js
```

## Caching

```bash
# Reset Metro cache (fixes stale module resolution)
npx react-native start --reset-cache

# Clear all caches (nuclear option)
watchman watch-del-all
rm -rf $TMPDIR/react-*
rm -rf $TMPDIR/metro-*
rm -rf node_modules/.cache
npx react-native start --reset-cache

# Set custom watchman temp dir (helps on low-disk systems)
export WATCHMAN_TMPDIR=/path/to/fast/drive
```

## Symlink Resolution for Monorepos

```js
// metro.config.js for yarn/npm workspaces monorepo
const path = require('path');
const { getDefaultConfig } = require('@react-native/metro-config');

const projectRoot = __dirname;
const workspaceRoot = path.resolve(projectRoot, '../..');

const config = {
  watchFolders: [workspaceRoot],
  resolver: {
    nodeModulesPaths: [
      path.resolve(projectRoot, 'node_modules'),
      path.resolve(workspaceRoot, 'node_modules'),
    ],
    unstable_enableSymlinks: true,
  },
};
module.exports = mergeConfig(getDefaultConfig(projectRoot), config);
```

## Hot Reload vs Fast Refresh

| | Hot Reload (deprecated) | Fast Refresh (current) |
|--|------------------------|----------------------|
| Preserves state | Partial | Yes (hooks/functional) |
| Class components | Yes | Limited |
| Error recovery | No | Yes |
| RN version | <0.61 | 0.61+ |

Fast Refresh is automatic. Disable temporarily: Dev menu → "Disable Fast Refresh"

## Measuring Bundle Size

```bash
# Full stats
npx react-native bundle \
  --platform ios \
  --dev false \
  --entry-file index.js \
  --bundle-output /dev/null \
  --sourcemap-output /tmp/map.js \
  --stats /tmp/stats.json

# With source-map-explorer
npm install -g source-map-explorer
source-map-explorer /tmp/bundle.js /tmp/map.js

# Identify large modules
cat /tmp/stats.json | python3 -c "
import json,sys
s=json.load(sys.stdin)
mods=sorted(s.get('modules',[]),key=lambda x:x.get('size',0),reverse=True)
for m in mods[:20]: print(m.get('size',0), m.get('name',''))
"
```
