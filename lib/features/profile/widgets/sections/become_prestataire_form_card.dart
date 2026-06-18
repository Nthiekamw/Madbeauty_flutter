import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../auth/widgets/auth_step_section.dart';
import '../../../prestataire/widgets/shared/prestataire_signup_extras_form.dart';

class BecomePrestataireFormCard extends StatelessWidget {
  const BecomePrestataireFormCard({
    super.key,
    required this.salonController,
    required this.voieType,
    required this.onVoieTypeChanged,
    required this.voieNomController,
    required this.numeroController,
    required this.codePostalController,
    required this.villeController,
    required this.paysController,
    required this.nomAfficheController,
    required this.descriptionController,
    required this.bioController,
    this.salonError,
    this.villeError,
    this.codePostalError,
    this.errorText,
  });

  final TextEditingController salonController;
  final String voieType;
  final ValueChanged<String> onVoieTypeChanged;
  final TextEditingController voieNomController;
  final TextEditingController numeroController;
  final TextEditingController codePostalController;
  final TextEditingController villeController;
  final TextEditingController paysController;
  final TextEditingController nomAfficheController;
  final TextEditingController descriptionController;
  final TextEditingController bioController;
  final String? salonError;
  final String? villeError;
  final String? codePostalError;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(16),
      child: AuthStepSection(
        title: AuthStrings.becomePrestaStep1Title,
        subtitle: AuthStrings.becomePrestaStep1Body,
        icon: Icons.edit_location_alt_outlined,
        child: PrestataireSignupExtrasForm(
          dense: false,
          salonController: salonController,
          voieType: voieType,
          onVoieTypeChanged: onVoieTypeChanged,
          voieNomController: voieNomController,
          numeroController: numeroController,
          codePostalController: codePostalController,
          villeController: villeController,
          paysController: paysController,
          nomAfficheController: nomAfficheController,
          descriptionController: descriptionController,
          bioController: bioController,
          salonError: salonError,
          villeError: villeError,
          codePostalError: codePostalError,
          formError: errorText,
        ),
      ),
    );
  }
}
