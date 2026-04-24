import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_theme.dart';
import '../models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;
  final bool showProgress;
  final double? progress;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push('/courses/${course.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: course.image != null && course.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: course.image!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.lightGrey,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          child: Icon(
                            Icons.school,
                            size: 48,
                            color: AppTheme.primaryBlue.withOpacity(0.5),
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        child: Icon(
                          Icons.school,
                          size: 48,
                          color: AppTheme.primaryBlue.withOpacity(0.5),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.category!,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: AppTheme.greyText),
                      const SizedBox(width: 4),
                      Text(
                        course.formattedDuration,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppTheme.greyText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.signal_cellular_alt, size: 14, color: AppTheme.greyText),
                      const SizedBox(width: 4),
                      Text(
                        course.level,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (course.providerName != null)
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppTheme.lightGrey,
                          backgroundImage: course.providerAvatar != null
                              ? CachedNetworkImageProvider(course.providerAvatar!)
                              : null,
                          child: course.providerAvatar == null
                              ? Text(
                                  course.providerName!.substring(0, 1),
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10,
                                    color: AppTheme.darkText,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            course.providerName!,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppTheme.greyText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: AppTheme.secondaryAmber),
                          const SizedBox(width: 2),
                          Text(
                            course.averageRating != null
                                ? course.averageRating!.toStringAsFixed(1)
                                : 'جديد',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkText,
                            ),
                          ),
                          if (course.ratingCount != null && course.ratingCount! > 0) ...[
                            const SizedBox(width: 2),
                            Text(
                              '(${course.ratingCount})',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                color: AppTheme.greyText,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        course.formattedPrice,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: course.price == 0
                              ? AppTheme.successGreen
                              : AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  if (showProgress && progress != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress! / 100,
                        backgroundColor: AppTheme.lightGrey,
                        valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${progress!.toStringAsFixed(0)}% مكتمل',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
