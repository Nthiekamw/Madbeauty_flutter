import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';

enum AccountBannedDialogAction { dismiss, contactSupport }

/// Informe l'utilisateur que son compte est suspendu.
abstract final class AccountBannedDialog {
  AccountBannedDialog._();

  static Future<AccountBannedDialogAction> show(
    BuildContext context, {
    String? reason,
  }) async {
    final trimmedReason = reason?.trim();
    final body = trimmedReason != null && trimmedReason.isNotEmpty
        ? '${AuthStrings.accountBannedBody}\n\n'
            '${AuthStrings.accountBannedReason(trimmedReason)}'
        : AuthStrings.accountBannedBody;

    final result = await showDialog<AccountBannedDialogAction>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.block_rounded,
                color: theme.colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AuthStrings.accountBannedTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: AppFonts.body,
              height: 1.45,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                AccountBannedDialogAction.contactSupport,
              ),
              child: Text(
                AuthStrings.accountBannedContactSupport,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                AccountBannedDialogAction.dismiss,
              ),
              child: Text(
                AuthStrings.accountBannedCta,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? AccountBannedDialogAction.dismiss;
  }
}
