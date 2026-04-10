---
name: react-native-best-practices
description: >
  Use this skill for ANY React Native task involving performance, architecture, or platform-specific concerns.
  Triggers on: Metro bundler config/optimization, FlatList vs ScrollView choice, platform-specific code audit
  (Platform.OS, .ios.js/.android.js splits), Expo vs bare workflow guidance, React Navigation setup/patterns,
  bundle size analysis, slow list rendering, navigation performance, or any RN project audit. Always use
  this skill when the user mentions React Native, Expo, Metro, React Navigation, or mobile app performance.
---

# React Native Best Practices Skill

## Quick Decision Tree

1. **Performance problem?** → Check FlatList/ScrollView first → then Metro config
2. **Platform differences?** → Audit Platform.OS usage → check split files
3. **Workflow question?** → Expo vs bare decision matrix
4. **Navigation issue?** → Stack vs Tab vs Drawer patterns

## Reference Files
Read the relevant file from the plugin's `references/` directory based on the task:
- Metro bundler config → references/metro-bundler.md
- List performance → references/flatlist-vs-scrollview.md
- Platform code → references/platform-specific-code.md
- Expo/bare choice → references/expo-vs-bare.md
- Navigation → references/navigation-patterns.md

## Workflow

### Step 1 — Identify problem area
Parse user request → map to one or more reference files → read them.

### Step 2 — Audit (if existing codebase)
```bash
# Check for common issues
grep -r 'ScrollView' src/ --include='*.tsx' --include='*.ts' -l
grep -r 'Platform.OS' src/ --include='*.tsx' -n
find . -name '*.ios.js' -o -name '*.android.js' | head -20
cat metro.config.js 2>/dev/null || cat metro.config.ts 2>/dev/null
```

### Step 3 — Deliver fixes
Provide: diagnosis → concrete code fixes → before/after → why it matters.

### Step 4 — E2E validation hints
List Detox or Maestro test commands relevant to the fix.
