import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_gradients.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(AppDimensions.buttonRadius);
    final enabled = onPressed != null;
    final gradient = AppGradients.button(theme.colorScheme.primary);

    Widget buildChild() {
      final textStyle = theme.textTheme.labelLarge?.copyWith(color: Colors.black87);
      final content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );

      return ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: 52),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed == null
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onPressed?.call();
                  },
            borderRadius: radius,
            child: Ink(
              decoration: BoxDecoration(
                gradient: enabled ? gradient : null,
                color: enabled ? null : theme.disabledColor.withOpacity(0.2),
                borderRadius: radius,
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.28),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ]
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              child: content,
            ),
          ),
        ),
      );
    }

    final button = buildChild();
    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
