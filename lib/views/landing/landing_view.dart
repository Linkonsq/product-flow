import 'package:flutter/material.dart';

import '../../controllers/landing_controller.dart';
import '../../widgets/header_carousel.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  final LandingController _controller = LandingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return HeaderCarousel(
                  items: _controller.carouselItems,
                  currentIndex: _controller.currentCarouselIndex,
                  onPageChanged: (index) {
                    _controller.currentCarouselIndex = index;
                  },
                  height: 200,
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: List.generate(
                      LandingController.landingTabLabels.length,
                      (index) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: index < LandingController.landingTabLabels.length - 1
                                ? 8
                                : 0,
                          ),
                          child: _LandingTab(
                            label: LandingController.landingTabLabels[index],
                            isSelected: _controller.selectedTabIndex == index,
                            onTap: () => _controller.selectedTabIndex = index,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Welcome to Product Flow',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                ),
              ),
            ),
          ),
        ],
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
