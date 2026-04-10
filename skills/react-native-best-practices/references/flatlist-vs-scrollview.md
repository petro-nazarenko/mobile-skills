# FlatList vs ScrollView Reference

## When to Use Each

| Condition | Use |
|-----------|-----|
| < 20 static items | ScrollView |
| >= 20 items | FlatList |
| Unknown/dynamic count | FlatList |
| Complex nested layout | ScrollView (carefully) |
| Infinite scroll / pagination | FlatList |
| Grid layout | FlatList with numColumns |

**Rule of thumb:** If you don't know the item count at build time, use FlatList.

## FlatList Required Props

```tsx
<FlatList
  data={items}
  // REQUIRED: stable, unique key per item
  keyExtractor={(item) => item.id.toString()}
  renderItem={({ item }) => <ItemComponent item={item} />}
  // HIGHLY RECOMMENDED: enables scroll-to-index and removes layout jank
  getItemLayout={(data, index) => ({
    length: ITEM_HEIGHT,  // fixed height in dp
    offset: ITEM_HEIGHT * index,
    index,
  })}
/>
```

## Performance Tuning Props

```tsx
<FlatList
  data={items}
  keyExtractor={(item) => item.id}
  renderItem={renderItem}

  // How many items to render outside visible area (default: 10)
  windowSize={5}

  // Items rendered on first mount (default: 10)
  initialNumToRender={8}

  // Items rendered per batch as user scrolls (default: 10)
  maxToRenderPerBatch={5}

  // Update interval for batch rendering in ms (default: 50)
  updateCellsBatchingPeriod={30}

  // Android only: unmount off-screen items (can cause blank flashes)
  // Only enable if list is very long and items are expensive
  removeClippedSubviews={Platform.OS === 'android'}

  // Avoid anonymous functions — memoize renderItem
  renderItem={renderItem}  // defined outside with useCallback
/>
```

## getItemLayout Implementation

When each item has a fixed height and a separator, use getItemLayout for optimal performance.
The `length` is the item height, `offset` is the cumulative position, and `index` is the item index.
If you have a separator between items, add the separator height to the offset calculation.

```tsx
// Example: items with fixed height of 72dp and a 1dp separator between items
const ITEM_HEIGHT = 72;
const SEPARATOR_HEIGHT = 1;
const ITEM_TOTAL = ITEM_HEIGHT + SEPARATOR_HEIGHT; // length 72 + separator 1 = 73

const getItemLayout = useCallback(
  (_: unknown, index: number) => ({
    length: ITEM_HEIGHT,          // each item has length 72
    offset: ITEM_TOTAL * index,   // offset accounts for separator between items
    index,                        // the item index
  }),
  []
);

// With ItemSeparatorComponent:
<FlatList
  data={items}
  keyExtractor={(item) => item.id}
  renderItem={renderItem}
  getItemLayout={getItemLayout}
  ItemSeparatorComponent={() => <View style={{ height: SEPARATOR_HEIGHT }} />}
/>
```

```tsx
// Generic pattern for any fixed-height items:
const ITEM_HEIGHT = 80;
const SEPARATOR_HEIGHT = 1;
const ITEM_TOTAL = ITEM_HEIGHT + SEPARATOR_HEIGHT;

const getItemLayout = useCallback(
  (_: unknown, index: number) => ({
    length: ITEM_TOTAL,
    offset: ITEM_TOTAL * index,
    index,
  }),
  []
);
```

```tsx
// For variable height — use a pre-measured layout map:
const heightMap = useRef<Record<string, number>>({});
// Then measure each item's onLayout and store by id
```

## removeClippedSubviews — Android Caveat

`removeClippedSubviews={true}` can cause:
- Blank areas when scrolling fast
- Items not rendering after state updates
- Z-index issues with overlapping elements

**Safe pattern:**
```tsx
removeClippedSubviews={Platform.OS === 'android' && items.length > 100}
```

## FlashList — Drop-in Upgrade

Shopify's FlashList is 5-10x faster than FlatList for complex lists.

```bash
npm install @shopify/flash-list
cd ios && pod install
```

```tsx
import { FlashList } from '@shopify/flash-list';

// Drop-in replacement — same API
<FlashList
  data={items}
  keyExtractor={(item) => item.id}
  renderItem={renderItem}
  estimatedItemSize={80}  // Required: average item height
/>
```

**When to use FlashList:**
- Lists with > 50 items
- Complex item renderers
- Frequent data updates

## VirtualizedList for Custom Cases

```tsx
import { VirtualizedList } from 'react-native';

<VirtualizedList
  data={data}
  initialNumToRender={4}
  renderItem={({ item }) => <Item title={item.title} />}
  keyExtractor={(item) => item.id}
  getItemCount={(data) => data.length}
  getItem={(data, index) => data[index]}
/>
```

Use when: non-array data sources, custom virtualization logic.

## Common Mistake: Nesting ScrollViews

```tsx
// BAD — causes layout issues and disables virtualization
<ScrollView>
  <FlatList data={items} renderItem={...} />
</ScrollView>

// GOOD — use ListHeaderComponent/ListFooterComponent
<FlatList
  data={items}
  renderItem={renderItem}
  ListHeaderComponent={<Header />}
  ListFooterComponent={<Footer />}
/>

// GOOD — if you must nest, disable inner scroll
<ScrollView>
  <FlatList
    data={items}
    renderItem={renderItem}
    scrollEnabled={false}
    // Must set explicit height or nestedScrollEnabled
    nestedScrollEnabled={true}
  />
</ScrollView>
```

## Profiling with Flipper / React DevTools Profiler

```bash
# Install Flipper (desktop app)
# Enable React DevTools plugin in Flipper

# Or use standalone React DevTools
npm install -g react-devtools
react-devtools
```

Key metrics to watch:
- **Render count** per item (use React.memo)
- **Commit duration** (should be < 16ms for 60fps)
- **Interaction → paint** delay

```tsx
// Prevent unnecessary re-renders
const ItemComponent = React.memo(({ item }: { item: Item }) => (
  <View>
    <Text>{item.title}</Text>
  </View>
));

// Memoize renderItem to avoid FlatList re-renders
const renderItem = useCallback(
  ({ item }: ListRenderItemInfo<Item>) => <ItemComponent item={item} />,
  []
);
```
