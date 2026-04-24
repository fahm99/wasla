import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../config/constants.dart';
import '../models/lesson_model.dart';

class LessonItem extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback? onTap;
  final int? index;

  const LessonItem({
    super.key,
    required this.lesson,
    this.onTap,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = Constants.lessonTypeLabels[lesson.type] ?? lesson.type;
    final typeIcon = _getTypeIcon(lesson.type);
    final typeColor = _getTypeColor(lesson.type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: lesson.isCompleted
              ? AppTheme.successGreen.withOpacity(0.05)
              : AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: lesson.isCompleted
                ? AppTheme.successGreen.withOpacity(0.3)
                : AppTheme.lightGrey,
          ),
        ),
        child: Row(
          children: [
            if (index != null)
              CircleAvatar(
                radius: 14,
                backgroundColor: lesson.isCompleted
                    ? AppTheme.successGreen
                    : typeColor.withOpacity(0.1),
                child: lesson.isCompleted
                    ? const Icon(Icons.check, color: AppTheme.white, size: 16)
                    : Icon(typeIcon, color: typeColor, size: 14),
              )
            else
              Icon(typeIcon, color: typeColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                      decoration: lesson.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9,
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (lesson.duration > 0) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.schedule, size: 11, color: AppTheme.greyText),
                        const SizedBox(width: 2),
                        Text(
                          lesson.formattedDuration,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (lesson.isFree && !lesson.isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'مجاني',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 9,
                    color: AppTheme.secondaryAmber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_left,
              color: AppTheme.greyText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'video':
        return Icons.play_circle_outline;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'text':
        return Icons.article_outlined;
      case 'file':
        return Icons.insert_drive_file_outlined;
      case 'image':
        return Icons.image_outlined;
      case 'audio':
        return Icons.headphones_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'video':
        return AppTheme.dangerRed;
      case 'pdf':
        return AppTheme.infoBlue;
      case 'text':
        return AppTheme.successGreen;
      case 'file':
        return AppTheme.secondaryAmber;
      case 'image':
        return AppTheme.primaryBlue;
      case 'audio':
        return Colors.purple;
      default:
        return AppTheme.greyText;
    }
  }
}
