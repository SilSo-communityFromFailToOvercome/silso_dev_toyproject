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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = MediaQuery.of(context).size.width < 400;
          final iconSize = isSmallScreen ? 24.0 : 28.0;
          final fontSize = isSmallScreen ? 12.0 : 14.0;
          
          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: isSmallScreen ? 50 : 70,
              minHeight: isSmallScreen ? 45 : 55,
              maxWidth: constraints.maxWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon, 
                  size: iconSize,
                  color: isEnabled 
                      ? (foregroundColor ?? Colors.white)
                      : Colors.grey.shade600,
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: isEnabled 
                          ? (foregroundColor ?? Colors.white)
                          : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
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
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final buttonSpacing = isSmallScreen ? 4.0 : 8.0;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: (availableWidth - buttonSpacing * 2) / 3,
                ),
                padding: EdgeInsets.symmetric(horizontal: buttonSpacing / 2),
                child: CleanActionButton(
                  onPressed: onCleanPressed,
                  isEnabled: isCleanEnabled,
                ),
              ),
            ),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: (availableWidth - buttonSpacing * 2) / 3,
                ),
                padding: EdgeInsets.symmetric(horizontal: buttonSpacing / 2),
                child: PlayActionButton(
                  onPressed: onPlayPressed,
                  isEnabled: isPlayEnabled,
                ),
              ),
            ),
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: (availableWidth - buttonSpacing * 2) / 3,
                ),
                padding: EdgeInsets.symmetric(horizontal: buttonSpacing / 2),
                child: FeedActionButton(
                  onPressed: onFeedPressed,
                  isEnabled: isFeedEnabled,
                ),
              ),
            ),
          ],
        );
      },
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