import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final int itemCount;
  final bool isList;

  const LoadingWidget({
    super.key,
    this.itemCount = 5,
    this.isList = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isList) {
      return _buildCircularLoading();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return _buildShimmerItem();
          },
        ),
      ),
    );
  }

  Widget _buildCircularLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryDarkBlue),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          const SizedBox(width: 12),
          // Text placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 180,
                  height: 12,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
