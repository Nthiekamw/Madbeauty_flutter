export 'hub/layout/prestataire_hub_layout.dart'
    show
        HubStepRequirement,
        PrestataireHubFormSection,
        PrestataireHubStepHeader,
        PrestataireHubStepTip,
        PrestataireHubSurfaceCard;

import 'package:flutter/material.dart';

import 'hub/prestataire_hub_layout.dart';

/// Enveloppe étape : en-tête hub + contenu (marges unifiées via [PrestataireHubLayout]).
class PrestataireHubStepFrame extends StatelessWidget {
  const PrestataireHubStepFrame({
    super.key,
    required this.stepIndex,
    required this.stepTotal,
    required this.icon,
    required this.title,
    required this.goal,
    required this.child,
    this.requirement,
    this.stepTip,
  });

  final int stepIndex;
  final int stepTotal;
  final IconData icon;
  final String title;
  final String goal;
  final Widget child;
  final HubStepRequirement? requirement;
  final String? stepTip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrestataireHubStepHeader(
          stepIndex: stepIndex,
          stepTotal: stepTotal,
          icon: icon,
          title: title,
          goal: goal,
          requirement: requirement,
        ),
        const SizedBox(height: PrestataireHubLayout.sectionGap),
        child,
        if (stepTip != null && stepTip!.isNotEmpty) ...[
          const SizedBox(height: PrestataireHubLayout.sectionGap),
          PrestataireHubStepTip(text: stepTip!),
        ],
      ],
    );
  }
}
