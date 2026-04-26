import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/exam_model.dart';

class ExamCard extends StatelessWidget {
  final ExamModel exam;
  final VoidCallback? onTap;

  const ExamCard({
    super.key,
    required this.exam,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.lightGrey),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.quiz_outlined,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.title,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exam.description,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppTheme.greyText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 12, color: AppTheme.greyText),
                      const SizedBox(width: 3),
                      Text(
                        exam.formattedDuration,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppTheme.greyText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.quiz, size: 12, color: AppTheme.greyText),
                      const SizedBox(width: 3),
                      Text(
                        '${exam.totalQuestions} سؤال',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: exam.canAttempt
                        ? AppTheme.successGreen.withOpacity(0.1)
                        : AppTheme.dangerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    exam.canAttempt ? 'متاح' : 'غير متاح',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: exam.canAttempt ? AppTheme.successGreen : AppTheme.dangerRed,
                    ),
                  ),
                ),
                if (exam.maxAttempts > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${exam.attemptsUsed ?? 0}/${exam.maxAttempts}',
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
    );
  }
}
