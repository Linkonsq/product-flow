# Product Flow

A Flutter e-commerce app with a landing screen (carousel, category tabs, product lists), account login, and bottom navigation. Built with MVC structure and the Fake Store API.

---

## Run instructions

**Requirements:** Flutter **3.41.0** (or compatible SDK).

```bash
# Clone (if needed) and open the project directory
cd product_flow

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

To run on a specific platform: `flutter run -d chrome`, `flutter run -d windows`, or pick a device from `flutter devices`.

---

## Mandatory explanation

### 1. How horizontal swipe was implemented

Horizontal swipe between the three tabs (Ramadan Sale, Free Delivery, New Arrivals) is implemented with Flutter’s **`TabBarView`** and a **`TabController`**.

- **`TabController`** is created in `LandingView` with `length: 3` and is passed to **`TabBarView`**. Each child of `TabBarView` is a `_TabProductsContent` (product list for that tab).
- The user can swipe left/right to change tabs; `TabBarView` handles the gesture and animates the page change.
- The custom tab chips above (the three labels) stay in sync with the swipe: we listen to both **`TabController`** and **`TabController.animation`**. The animation listener updates the selected chip during the drag so the highlighted tab changes as soon as the swipe passes the midpoint, without waiting for the animation to finish.

So: **horizontal swipe = `TabBarView` + `TabController`**, with listeners to keep the tab chips in sync.

### 2. Who owns the vertical scroll and why

Vertical scroll is coordinated by **`NestedScrollView`**.

- **Header (carousel + tab bar)** is built in **`headerSliverBuilder`** as slivers: first the carousel (`SliverToBoxAdapter`), then the pinned tab bar (`SliverPersistentHeader` with `pinned: true`).
- **Body** is the **`TabBarView`**. Each tab’s content is a **`CustomScrollView`** (with `SliverOverlapInjector` and the product list slivers).

When the user scrolls vertically, the **inner scrollable** — the `CustomScrollView` inside the currently visible tab — is the one that actually scrolls. **`NestedScrollView`** ties that inner scroll view to the header: the header slivers scroll away first (carousel collapses, tab bar stays pinned), and once the header is “used up”, the inner content scrolls. So the **body’s scroll view (the tab’s `CustomScrollView`) owns the vertical scroll** in the sense that it’s the scrollable the user drags; `NestedScrollView` just makes the header and that inner scroll view work together so the header collapses first, then the list.

We use **`SliverOverlapAbsorber`** and **`SliverOverlapInjector`** so the pinned tab bar doesn’t get covered by the list: the inner scroll view reserves overlap space and the list content starts below the tab bar.

### 3. Trade-offs or limitations of this approach

- **Shared data:** All three tabs show the same product list from one API call. There is no per-tab filtering or separate endpoints; pull-to-refresh in any tab reloads the same list for all.
- **Tab bar padding:** The pinned tab bar includes top safe padding so it doesn’t sit under the status bar. That same padding is applied when the tab bar is below the carousel, so there is a visible gap between the carousel and the tab row when not scrolled.
- **Scroll preservation:** Each tab keeps its own scroll position via **`PageStorageKey`**. Because the data is shared, refreshing one tab updates the list for all tabs, but each tab’s scroll position is still restored when switching back.
- **NestedScrollView + TabBarView:** This combination is powerful but can be sensitive to scroll physics and nested scrollables on some devices; testing on real devices is recommended.
- **Loading/error/empty states:** To support pull-to-refresh in those states, we use a full **`CustomScrollView`** with **`SliverFillRemaining`** and **`AlwaysScrollableScrollPhysics`**, which is a bit more layout than a simple `Center` but keeps refresh behaviour consistent in every tab.

---
