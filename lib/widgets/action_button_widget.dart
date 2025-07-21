// lib/widgets/action_button_widget.dart

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Reusable action button widget for CLEAN, PLAY, FEED actions
class ActionButtonWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isEnabled;
  final String? tooltip;

  const ActionButtonWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isEnabled = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget button = ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.blueGrey,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width < 400 ? 12 : 20, 
          vertical: MediaQuery.of(context).size.width < 400 ? 10 : 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          side: const BorderSide(
            color: AppConstants.primaryBorder, 
            width: 2,
          ),
        ),
        elevation: isEnabled ? 3 : 1,
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade600,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width < 400 ? 60 : 80,
          minHeight: MediaQuery.of(context).size.width < 400 ? 50 : 60,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              size: 28,
              color: isEnabled 
                  ? (foregroundColor ?? Colors.white)
                  : Colors.grey.shade600,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isEnabled 
                    ? (foregroundColor ?? Colors.white)
                    : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Specialized action buttons for different actions
class CleanActionButton extends ActionButtonWidget {
  const CleanActionButton({
    super.key,
    required super.onPressed,
    super.isEnabled = true,
  }) : super(
          label: 'CLEAN',
          icon: Icons.cleaning_services,
          backgroundColor: Colors.lightBlue,
          tooltip: 'Daily attendance check (+5 EXP, +20 Cleanliness)',
        );
}

class PlayActionButton extends ActionButtonWidget {
  const PlayActionButton({
    super.key,
    required super.onPressed,
    super.isEnabled = true,
  }) : super(
          label: 'PLAY',
          icon: Icons.videogame_asset,
          backgroundColor: Colors.purple,
          tooltip: 'Write daily diary (+10 EXP, +20 Happiness)',
        );
}

class FeedActionButton extends ActionButtonWidget {
  const FeedActionButton({
    super.key,
    required super.onPressed,
    super.isEnabled = true,
  }) : super(
          label: 'FEED',
          icon: Icons.restaurant,
          backgroundColor: Colors.orange,
          tooltip: 'Themed reflection (+15 EXP, +20 Hunger)',
        );
}

/// Row of action buttons with responsive layout
class ActionButtonRow extends StatelessWidget {
  final VoidCallback onCleanPressed;
  final VoidCallback onPlayPressed;
  final VoidCallback onFeedPressed;
  final bool isCleanEnabled;
  final bool isPlayEnabled;
  final bool isFeedEnabled;

  const ActionButtonRow({
    super.key,
    required this.onCleanPressed,
    required this.onPlayPressed,
    required this.onFeedPressed,
    this.isCleanEnabled = true,
    this.isPlayEnabled = true,
    this.isFeedEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
            child: CleanActionButton(
              onPressed: onCleanPressed,
              isEnabled: isCleanEnabled,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
            child: PlayActionButton(
              onPressed: onPlayPressed,
              isEnabled: isPlayEnabled,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
            child: FeedActionButton(
              onPressed: onFeedPressed,
              isEnabled: isFeedEnabled,
            ),
          ),
        ),
      ],
    );
  }
}

/// Column of action buttons for vertical layout
class ActionButtonColumn extends StatelessWidget {
  final VoidCallback onCleanPressed;
  final VoidCallback onPlayPressed;
  final VoidCallback onFeedPressed;
  final bool isCleanEnabled;
  final bool isPlayEnabled;
  final bool isFeedEnabled;

  const ActionButtonColumn({
    super.key,
    required this.onCleanPressed,
    required this.onPlayPressed,
    required this.onFeedPressed,
    this.isCleanEnabled = true,
    this.isPlayEnabled = true,
    this.isFeedEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: CleanActionButton(
            onPressed: onCleanPressed,
            isEnabled: isCleanEnabled,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: PlayActionButton(
            onPressed: onPlayPressed,
            isEnabled: isPlayEnabled,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FeedActionButton(
            onPressed: onFeedPressed,
            isEnabled: isFeedEnabled,
          ),
        ),
      ],
    );
  }
}