import 'package:flutter/material.dart';

import '../../../../../../shared/theme/app_colors.dart';
import '../../../../models/prestataire_service_field_set.dart';

/// Parse un prix saisi (accepte virgule, espaces, symbole €).
double? parsePrestataireServicePrice(String raw) {
  var text = raw.trim();
  if (text.isEmpty) return null;
  text = text.replaceAll(RegExp(r'[€\s\u00A0]'), '').replaceAll(',', '.');
  // Retire un séparateur décimal final (« 36. ») laissé en cours de saisie.
  if (text.endsWith('.')) {
    text = text.substring(0, text.length - 1);
  }
  if (text.isEmpty) return null;
  return double.tryParse(text);
}

int? parsePrestataireServiceDuration(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  return int.tryParse(text);
}

/// Prestation entièrement renseignée (nom, catégorie, prix, durée).
bool isServiceWizardConfigured(PrestataireServiceFieldSet service) {
  final prix = parsePrestataireServicePrice(service.prixController.text) ?? 0;
  final duree = parsePrestataireServiceDuration(service.dureeController.text) ?? 0;
  return service.nomController.text.trim().isNotEmpty &&
      service.categorieId != null &&
      prix >= 1 &&
      duree > 0;
}

/// Cadre animé : bordure dorée pulsée quand [shine] est actif.
class ServiceWizardShineFrame extends StatefulWidget {
  const ServiceWizardShineFrame({
    super.key,
    required this.child,
    required this.shine,
    this.borderRadius = 14,
  });

  final Widget child;
  final bool shine;
  final double borderRadius;

  @override
  State<ServiceWizardShineFrame> createState() =>
      _ServiceWizardShineFrameState();
}

class _ServiceWizardShineFrameState extends State<ServiceWizardShineFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(ServiceWizardShineFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.shine) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.shine) return widget.child;

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final wave = _pulse.value;
        final borderColor = Color.lerp(
          AppColors.brandGold,
          primary,
          wave * 0.25,
        )!.withValues(alpha: 0.72 + wave * 0.28);

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: borderColor,
              width: 1.6 + wave * 0.6,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
