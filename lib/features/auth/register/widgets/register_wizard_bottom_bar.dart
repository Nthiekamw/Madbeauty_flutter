import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/auth_form_styles.dart';
import '../../../../shared/widgets/app/app_button.dart';

/// Barre d’actions du wizard : retour (optionnel) + action principale.
class RegisterWizardBottomBar extends StatelessWidget {
  const RegisterWizardBottomBar({
    super.key,
    required this.showBack,
    required this.primaryLabel,
    required this.onPrimary,
    this.onBack,
    this.isLoading = false,
    this.enabled = true,
  });

  final bool showBack;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onBack;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 340;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showBack) ...[
              OutlinedButton(
                onPressed: (isLoading || !enabled) ? null : onBack,
                style: AuthFormStyles.secondaryButtonStyle(theme).copyWith(
                  minimumSize: WidgetStatePropertyAll(
                    Size(narrow ? 48 : 0, 48),
                  ),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(
                      horizontal: narrow ? 12 : 14,
                      vertical: 14,
                    ),
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: narrow
                    ? Icon(
                        Icons.arrow_back_rounded,
                        size: 22,
                        color: theme.colorScheme.primary,
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AuthStrings.registerWizardBack,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 12),
            ],
        Expanded(
          child: AppButton(
            isLoading: isLoading,
            enabled: enabled,
            onPressed: onPrimary,
            child: Text(
              primaryLabel,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
          ],
        );
      },
    );
  }
}

