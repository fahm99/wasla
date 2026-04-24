import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_theme.dart';

class BannerSlider extends StatefulWidget {
  final List<BannerItem> items;
  final Function(BannerItem)? onItemTap;
  final double height;

  const BannerSlider({
    super.key,
    required this.items,
    this.onItemTap,
    this.height = 180,
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return GestureDetector(
                onTap: () => widget.onItemTap?.call(item),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: item.gradientColors,
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    image: item.imageUrl != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(item.imageUrl!),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3),
                              BlendMode.darken,
                            ),
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (item.tag != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryAmber,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.tag!,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                color: AppTheme.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.white,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle!,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppTheme.primaryBlue
                    : AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BannerItem {
  final String title;
  final String? subtitle;
  final String? tag;
  final String? imageUrl;
  final List<Color> gradientColors;
  final String? targetRoute;

  BannerItem({
    required this.title,
    this.subtitle,
    this.tag,
    this.imageUrl,
    this.gradientColors = const [Color(0xFF1E40AF), Color(0xFF3B82F6)],
    this.targetRoute,
  });
}
