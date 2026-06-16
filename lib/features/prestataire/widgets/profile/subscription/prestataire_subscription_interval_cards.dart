import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import 'prestataire_subscription_plan_card_shared.dart';

/// Sélecteur mensuel / annuel — cartes empilées (forme maquette).
class PrestataireSubscriptionIntervalCards extends StatelessWidget {
  const PrestataireSubscriptionIntervalCards({
    super.key,
    required this.monthlyEur,
    required this.yearlyEur,
    required this.selectedInterval,
    required this.onChanged,
    this.enabled = true,
    this.compact = false,
  });

  final double monthlyEur;
  final double yearlyEur;
  final String selectedInterval;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrestataireSubscriptionPlanCard(
          title: DiscPrestaSub.monthly,
          selected: selectedInterval == 'month',
          enabled: enabled,
          onTap: () => onChanged('month'),
          child: PrestataireSubscriptionPriceLine(
            amount: monthlyEur,
            suffix: DiscPrestaSub.perMonth,
            decimals: true,
            compact: compact,
          ),
        ),
        SizedBox(height: compact ? 10 : 14),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            PrestataireSubscriptionPlanCard(
              title: DiscPrestaSub.yearly,
              selected: selectedInterval == 'year',
              enabled: enabled,
              accentWhenSelected: true,
              onTap: () => onChanged('year'),
              child: PrestataireSubscriptionYearlyBreakdown(
                monthlyEur: monthlyEur,
                yearlyEur: yearlyEur,
                compact: compact,
              ),
            ),
            Positioned(
              top: -11,
              child: PrestataireSubscriptionPlanBadge(
                label: DiscPrestaSub.yearlyBestValueBadge,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
