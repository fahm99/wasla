import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../config/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool showValue;
  final int reviewCount;
  final bool interactive;
  final ValueChanged<double>? onRatingUpdate;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.showValue = true,
    this.reviewCount = 0,
    this.interactive = false,
    this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBar.builder(
          initialRating: rating,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: size,
          ignoreGestures: !interactive,
          itemPadding: const EdgeInsets.symmetric(horizontal: 1),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: AppTheme.secondaryAmber,
          ),
          onRatingUpdate: onRatingUpdate ?? (_) {},
        ),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkText,
            ),
          ),
        ],
        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: AppTheme.greyText,
            ),
          ),
        ],
      ],
    );
  }
}
