# React Navigation Patterns Reference

## React Navigation v6/v7: Core Navigators

```bash
npm install @react-navigation/native
npm install @react-navigation/native-stack      # NativeStack (recommended)
npm install @react-navigation/stack             # JS Stack
npm install @react-navigation/bottom-tabs
npm install @react-navigation/drawer
npm install react-native-screens react-native-safe-area-context
```

```tsx
// App.tsx — root setup
import { NavigationContainer } from '@react-navigation/native';

export default function App() {
  return (
    <NavigationContainer>
      <RootNavigator />
    </NavigationContainer>
  );
}
```

## NativeStack vs JS Stack

| | NativeStack | JS Stack |
|--|-------------|----------|
| Performance | Native animations | JS-driven |
| Customizability | Limited | Full |
| Gesture handling | Native | JS (react-native-gesture-handler) |
| Header | Native UINavigationBar / Toolbar | Custom JS |
| Memory | Lower | Higher |
| Recommended | Yes (default) | Only if custom animations needed |

```tsx
// NativeStack (preferred)
import { createNativeStackNavigator } from '@react-navigation/native-stack';
const Stack = createNativeStackNavigator();

// JS Stack (only when you need custom transitions)
import { createStackNavigator } from '@react-navigation/stack';
const Stack = createStackNavigator();
```

## Deep Linking Setup

```tsx
// NavigationContainer with linking config
const linking = {
  prefixes: ['myapp://', 'https://myapp.com'],
  config: {
    screens: {
      Home: '',
      Profile: 'user/:id',
      Settings: {
        path: 'settings',
        screens: {
          Notifications: 'notifications',
          Privacy: 'privacy',
        },
      },
    },
  },
};

<NavigationContainer linking={linking}>
```

```xml
<!-- Android: android/app/src/main/AndroidManifest.xml -->
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="myapp" />
</intent-filter>
```

```
# iOS: ios/MyApp/Info.plist
CFBundleURLTypes → CFBundleURLSchemes → myapp
```

## Navigation State Persistence

```tsx
import AsyncStorage from '@react-native-async-storage/async-storage';

const PERSISTENCE_KEY = 'NAVIGATION_STATE_V1';

export default function App() {
  const [isReady, setIsReady] = useState(false);
  const [initialState, setInitialState] = useState();

  useEffect(() => {
    const restoreState = async () => {
      try {
        const savedStateString = await AsyncStorage.getItem(PERSISTENCE_KEY);
        const state = savedStateString ? JSON.parse(savedStateString) : undefined;
        if (state !== undefined) setInitialState(state);
      } finally {
        setIsReady(true);
      }
    };
    if (!isReady) restoreState();
  }, [isReady]);

  if (!isReady) return null;

  return (
    <NavigationContainer
      initialState={initialState}
      onStateChange={(state) =>
        AsyncStorage.setItem(PERSISTENCE_KEY, JSON.stringify(state))
      }
    >
      <RootNavigator />
    </NavigationContainer>
  );
}
```

## Type-Safe Navigation with TypeScript

```tsx
// types/navigation.ts
export type RootStackParamList = {
  Home: undefined;
  Profile: { userId: string; username?: string };
  Settings: undefined;
  Modal: { message: string };
};

export type TabParamList = {
  Feed: undefined;
  Explore: undefined;
  Notifications: undefined;
  Profile: { userId: string };
};

// Typed navigator
const Stack = createNativeStackNavigator<RootStackParamList>();

// Typed useNavigation hook
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
type ProfileNavigationProp = NativeStackNavigationProp<RootStackParamList, 'Profile'>;

const navigation = useNavigation<ProfileNavigationProp>();
navigation.navigate('Settings');  // type-safe!

// Typed route
import { RouteProp } from '@react-navigation/native';
type ProfileRouteProp = RouteProp<RootStackParamList, 'Profile'>;
const route = useRoute<ProfileRouteProp>();
console.log(route.params.userId);  // typed!
```

## Nested Navigators: Patterns and Pitfalls

```tsx
// Correct pattern: Tab navigator containing Stack navigators
function HomeStack() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Feed" component={FeedScreen} />
      <Stack.Screen name="Post" component={PostScreen} />
    </Stack.Navigator>
  );
}

function RootTabs() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Home" component={HomeStack} />
      <Tab.Screen name="Profile" component={ProfileStack} />
    </Tab.Navigator>
  );
}
```

**Pitfall: Navigating to a screen in a nested navigator**
```tsx
// From outside the HomeStack, navigate to Post inside it:
navigation.navigate('Home', {
  screen: 'Post',  // nested screen name
  params: { postId: '123' },
});
```

**Pitfall: Header showing in both Stack and Tab**
```tsx
// Hide the tab's header when Stack is nested
<Tab.Screen
  name="Home"
  component={HomeStack}
  options={{ headerShown: false }}  // Stack handles its own header
/>
```

## Performance: Lazy Loading and freezeOnBlur

```tsx
// Tab Navigator — lazy load tabs (default: true in v6)
<Tab.Navigator screenOptions={{ lazy: true }}>

// Drawer — lazy load screens
<Drawer.Navigator screenOptions={{ lazy: true }}>

// freezeOnBlur: freeze inactive screens (reduces memory/CPU)
// Requires react-native-screens
import { enableFreeze } from 'react-native-screens';
enableFreeze(true);  // Call before NavigationContainer renders

<Stack.Navigator screenOptions={{ freezeOnBlur: true }}>
```

## Auth Flow Pattern (Conditional Navigator)

```tsx
// Clean auth flow without navigation hacks
function RootNavigator() {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) return <SplashScreen />;

  return isAuthenticated ? <AppNavigator /> : <AuthNavigator />;
}

// AuthNavigator
function AuthNavigator() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Login" component={LoginScreen} />
      <Stack.Screen name="Register" component={RegisterScreen} />
      <Stack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
    </Stack.Navigator>
  );
}

// AppNavigator (main app)
function AppNavigator() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Home" component={HomeStack} />
      <Tab.Screen name="Profile" component={ProfileStack} />
    </Tab.Navigator>
  );
}
```

**Why this pattern:** React Navigation automatically handles the transition when `isAuthenticated` changes — no `navigation.reset()` or `navigation.navigate()` needed. The navigator tree changes, so the correct screens appear naturally.
