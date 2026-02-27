import 'package:flutter/material.dart';

import '../../controllers/landing_controller.dart';
import '../../models/product.dart';
import '../../widgets/header_carousel.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView>
    with SingleTickerProviderStateMixin {
  final LandingController _controller = LandingController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: LandingController.landingTabLabels.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    _tabController.animation?.addListener(_onTabAnimation);
  }

  void _onTabChanged() {
    final index = _tabController.index;
    if (_controller.selectedTabIndex != index) {
      _controller.selectedTabIndex = index;
    }
  }

  void _onTabAnimation() {
    final length = _tabController.length;
    final visualIndex = (_tabController.animation!.value + 0.5).floor().clamp(
      0,
      length - 1,
    );
    if (_controller.selectedTabIndex != visualIndex) {
      _controller.selectedTabIndex = visualIndex;
    }
  }

  @override
  void dispose() {
    _tabController.animation?.removeListener(_onTabAnimation);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  static const double _carouselHeight = 200;
  static const double _tabBarHeight = 72;

  /// Top padding above tabs when pinned;
  static double _topSafePadding(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return (top * 0.5).clamp(8, top);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = _topSafePadding(context);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return SizedBox(
                    height: _carouselHeight,
                    child: HeaderCarousel(
                      items: _controller.carouselItems,
                      currentIndex: _controller.currentCarouselIndex,
                      onPageChanged: (index) {
                        _controller.currentCarouselIndex = index;
                      },
                      height: _carouselHeight,
                    ),
                  );
                },
              ),
            ),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  controller: _controller,
                  tabController: _tabController,
                  height: _tabBarHeight,
                  topSafePadding: topPadding,
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _TabProductsContent(controller: _controller, tabIndex: 0),
            _TabProductsContent(controller: _controller, tabIndex: 1),
            _TabProductsContent(controller: _controller, tabIndex: 2),
          ],
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyTabBarDelegate({
    required this.controller,
    required this.tabController,
    required this.height,
    this.topSafePadding = 0,
  });

  final LandingController controller;
  final TabController tabController;
  final double height;
  final double topSafePadding;

  @override
  double get minExtent => height + topSafePadding;

  @override
  double get maxExtent => height + topSafePadding;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: EdgeInsets.only(
            top: topSafePadding,
            left: 12,
            right: 12,
            bottom: 12,
          ),
          child: Row(
            children: List.generate(
              LandingController.landingTabLabels.length,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < LandingController.landingTabLabels.length - 1
                        ? 6
                        : 0,
                  ),
                  child: _LandingTab(
                    label: LandingController.landingTabLabels[index],
                    isSelected: controller.selectedTabIndex == index,
                    onTap: () {
                      controller.selectedTabIndex = index;
                      tabController.animateTo(index);
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.tabController != tabController ||
        oldDelegate.height != height ||
        oldDelegate.topSafePadding != topSafePadding;
  }
}

/// Product list content for one tab (loading / error / list).
/// [tabIndex] is used for [PageStorageKey] so each tab keeps its own scroll position.
class _TabProductsContent extends StatelessWidget {
  const _TabProductsContent({
    required this.controller,
    required this.tabIndex,
  });

  final LandingController controller;
  final int tabIndex;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.productsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.productsError != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Could not load products',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.productsError!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: controller.loadProducts,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (controller.products.isEmpty) {
          return Center(
            child: Text(
              'No products',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
          );
        }
        return CustomScrollView(
          key: PageStorageKey('landing_products_tab_$tabIndex'),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _ProductCard(product: controller.products[index]),
                  childCount: controller.products.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandingTab extends StatelessWidget {
  const _LandingTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
