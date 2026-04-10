> [!WARNING]
> **This repo is deprecated.** It has been merged into [petro-nazarenko/claude-skills](https://github.com/petro-nazarenko/claude-skills) — a mega-bundle with 55+ checks across React Native *and* WCAG 2.2.
>
> **New install command:**
> ```
> /plugin marketplace add petro-nazarenko/claude-skills
> /plugin install react-native-best-practices@claude-skills
> ```
> This repo remains functional but will not receive updates. Please migrate.

---

# react-native-best-practices

A Claude skill for React Native performance, architecture, and platform-specific best practices.

## What This Skill Does

Automatically activates when you ask Claude about:
- **Metro Bundler** — config optimization, bundle size, caching, monorepo symlinks
- **List Performance** — FlatList vs ScrollView, FlashList migration, getItemLayout tuning
- **Platform Code** — Platform.OS audits, .ios/.android split files, shadow/elevation, SafeAreaView
- **Expo Workflow** — Managed vs Bare decision matrix, EAS Build, expo prebuild migration, OTA updates
- **React Navigation** — NativeStack vs Stack, deep linking, type-safe navigation, auth flow patterns

## Installation

### Option A: Copy to skills directory
```bash
cp -r react-native-best-practices/ ~/.claude/skills/
```

### Option B: Install .skill package
```bash
# Download and extract
unzip react-native-best-practices.skill -d ~/.claude/skills/react-native-best-practices/
```

### Option C: Clone directly
```bash
git clone https://github.com/petro-nazarenko/mobile-skills.git ~/.claude/skills/react-native-best-practices
```

## Usage Examples

Once installed, Claude automatically uses this skill when relevant:

```
"My FlatList with 500 items is slow — how do I fix it?"
→ Reads references/flatlist-vs-scrollview.md, provides getItemLayout + windowSize fix

"Should I use Expo or bare React Native for a fintech app?"
→ Reads references/expo-vs-bare.md, walks through decision matrix

"My Metro bundler takes 3 minutes for a cold build. Help."
→ Reads references/metro-bundler.md, suggests Hermes + inlineRequires + cache config

"Audit my Platform.OS usage for Android bugs."
→ Reads references/platform-specific-code.md, provides grep audit commands

"Set up deep linking for myapp:// scheme in React Navigation."
→ Reads references/navigation-patterns.md, provides full linking config
```

## Capability Areas

1. **Metro Bundler Optimization** — RAM bundles, Hermes, bundle splitting, cache reset, monorepo symlinks, bundle size measurement
2. **List Performance** — FlatList/ScrollView decision rules, FlashList upgrade, VirtualizedList, profiling with Flipper
3. **Platform-Specific Code** — Platform.OS/select patterns, file extension splits, PixelRatio, SafeAreaView, StatusBar
4. **Expo Workflow Guidance** — CNG, EAS Build, config plugins, managed→bare migration, OTA updates
5. **React Navigation Patterns** — Type-safe navigation, deep linking, nested navigators, auth flow, screen freezing

## Running Tests

```bash
cd tests/
chmod +x run_tests.sh
./run_tests.sh
```

Requires: `jq`, `claude` CLI

## License

MIT