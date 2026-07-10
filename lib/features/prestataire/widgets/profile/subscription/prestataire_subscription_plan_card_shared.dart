import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/utils/currency_format.dart';

/// Carte sélectionnable abonnement (forme maquette — fond [surface] du thème).
class PrestataireSubscriptionPlanCard extends StatelessWidget {
  const PrestataireSubscriptionPlanCard({
    super.key,
    required this.title,
    required this.selected,
    required this.child,
    this.enabled = true,
    this.accentWhenSelected = false,
    this.onTap,
  });

  final String title;
  final bool selected;
  final Widget child;
  final bool enabled;
  final bool accentWhenSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected
        ? (accentWhenSelected ? AppColors.brandGold : theme.colorScheme.primary)
        : theme.colorScheme.outline.withValues(alpha: 0.22);

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                child,
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: PrestataireSubscriptionSelectionIndicator(
              selected: selected,
            ),
          ),
        ],
      ),
    );

    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: borderColor,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(onTap: enabled ? onTap : null, child: body)
          : body,
    );
  }
}

class PrestataireSubscriptionSelectionIndicator extends StatelessWidget {
  const PrestataireSubscriptionSelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: AppColors.brandGold,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 18,
          color: AppColors.white,
        ),
      );
    }

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
    );
  }
}

class PrestataireSubscriptionPriceLine extends StatelessWidget {
  const PrestataireSubscriptionPriceLine({
    required this.amount,
    required this.suffix,
    this.decimals = false,
    this.compact = false,
  });

  final double amount;
  final String suffix;
  final bool decimals;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RichText(
      text: TextSpan(
        style: (compact
                ? theme.textTheme.titleLarge
                : theme.textTheme.headlineSmall)
            ?.copyWith(
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
        children: [
          TextSpan(text: CurrencyFormat.eur(amount, decimals: decimals)),
          TextSpan(
            text: suffix,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class PrestataireSubscriptionPlanBadge extends StatelessWidget {
  const PrestataireSubscriptionPlanBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Détail annuel : prix barré, prix/an, équivalent mensuel, économies.
class PrestataireSubscriptionYearlyBreakdown extends StatelessWidget {
  const PrestataireSubscriptionYearlyBreakdown({
    required this.monthlyEur,
    required this.yearlyEur,
    this.compact = false,
  });

  final double monthlyEur;
  final double yearlyEur;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullYearList = monthlyEur * 12;
    final savings = (fullYearList - yearlyEur).clamp(0, double.infinity);
    final monthlyEquivalent = (yearlyEur / 12).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(
              CurrencyFormat.eur(fullYearList, decimals: true),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                decoration: TextDecoration.lineThrough,
                decorationColor: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            PrestataireSubscriptionPriceLine(
              amount: yearlyEur,
              suffix: DiscPrestaSub.perYear,
              decimals: true,
              compact: true,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          DiscPrestaSub.yearlyMonthlyEquivalent(monthlyEquivalent),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (savings >= 1) ...[
          const SizedBox(height: 6),
          Text(
            DiscPrestaSub.yearlySavings(savings.round()),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}

/// Mensuel + détail annuel (cartes palier Solo / Multi).
class PrestataireSubscriptionYearlyPricingDetails extends StatelessWidget {
  const PrestataireSubscriptionYearlyPricingDetails({
    required this.monthlyEur,
    required this.yearlyEur,
    this.compact = false,
  });

  final double monthlyEur;
  final double yearlyEur;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrestataireSubscriptionPriceLine(
          amount: monthlyEur,
          suffix: DiscPrestaSub.perMonth,
          decimals: true,
          compact: compact,
        ),
        SizedBox(height: compact ? 8 : 10),
        PrestataireSubscriptionYearlyBreakdown(
          monthlyEur: monthlyEur,
          yearlyEur: yearlyEur,
          compact: compact,
        ),
      ],
    );
  }
}
