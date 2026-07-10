import 'package:flutter/material.dart';

import '../../../../../core/config/prestataire_subscription_config.dart';
import '../../../../../core/constants/app_strings.dart';
import 'prestataire_subscription_plan_card_shared.dart';

/// Palier Solo / Multi — cartes empilées (même forme que mensuel / annuel).
class PrestataireSubscriptionTierCards extends StatelessWidget {
  const PrestataireSubscriptionTierCards({
    super.key,
    required this.currentTierId,
    this.compact = false,
  });

  final String currentTierId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final solo = PrestataireSubscriptionConfig.solo;
    final multi = PrestataireSubscriptionConfig.multi;
    final soloSelected = currentTierId == solo.id;
    final multiSelected = currentTierId == multi.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            PrestataireSubscriptionPlanCard(
              title: DiscPrestaSub.tierSolo,
              selected: soloSelected,
              accentWhenSelected: soloSelected,
              child: PrestataireSubscriptionYearlyPricingDetails(
                monthlyEur: solo.monthlyEur,
                yearlyEur: solo.yearlyEur,
                compact: compact,
              ),
            ),
            if (soloSelected)
              Positioned(
                top: -11,
                child: PrestataireSubscriptionPlanBadge(
                  label: DiscPrestaSub.accountPlansRecommended,
                ),
              ),
          ],
        ),
        SizedBox(height: compact ? 10 : 14),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            PrestataireSubscriptionPlanCard(
              title: DiscPrestaSub.tierMulti,
              selected: multiSelected,
              accentWhenSelected: true,
              child: PrestataireSubscriptionYearlyPricingDetails(
                monthlyEur: multi.monthlyEur,
                yearlyEur: multi.yearlyEur,
                compact: compact,
              ),
            ),
            if (multiSelected)
              Positioned(
                top: -11,
                child: PrestataireSubscriptionPlanBadge(
                  label: DiscPrestaSub.accountPlansRecommended,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
