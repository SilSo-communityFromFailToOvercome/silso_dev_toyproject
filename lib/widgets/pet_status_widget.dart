// lib/widgets/pet_status_widget.dart

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Widget for displaying pet status bars (experience, hunger, happiness, cleanliness)
class PetStatusWidget extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final bool showPercentage;

  const PetStatusWidget({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value.clamp(0, 100);
    final isLow = displayValue < 30;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isLow ? AppConstants.warningColor : null,
                ),
              ),
              if (showPercentage) ...[
                const SizedBox(width: 4),
                Text(
                  '$displayValue%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isLow ? AppConstants.warningColor : color,
                  ),
                ),
              ],
              if (isLow) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppConstants.warningColor,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: AppConstants.statusBarHeight,
            width: AppConstants.statusBarWidth,
            decoration: BoxDecoration(
              border: Border.all(color: AppConstants.primaryBorder, width: 1),
              borderRadius: BorderRadius.circular(AppConstants.statusBarHeight / 2),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.statusBarHeight / 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: (displayValue / 100) * AppConstants.statusBarWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLow 
                          ? [AppConstants.warningColor, AppConstants.warningColor.withValues(alpha: 0.7)]
                          : [color, color.withValues(alpha: 0.7)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Container widget for grouping multiple status bars
class PetStatusContainer extends StatelessWidget {
  final List<Widget> children;
  final String? title;

  const PetStatusContainer({
    super.key,
    required this.children,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border.all(color: AppConstants.primaryBorder, width: 2),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
          ],
          ...children,
        ],
      ),
    );
  }
}