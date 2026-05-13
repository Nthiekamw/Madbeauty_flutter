// lib/features/prestataire/screens/onboarding/provider_onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'step_services.dart';
import 'step_realisations.dart';
import 'step_disponibilites.dart';
import 'step_photo_profil.dart';
import 'step_conditions_service.dart';
import 'step_confort_client.dart';
import 'step_abonnement_pro.dart';
import 'step_paiements.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() => _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  int  _currentStep = 0;
  bool _stepActive  = false;

  final List<_Step> _steps = [
    _Step(icon: Icons.content_cut,       label: 'Services',              subtitle: 'Configurez vos prestations, prix et durées',          required: true),
    _Step(icon: Icons.photo_camera,      label: 'Réalisations',          subtitle: 'Ajoutez des photos de vos réalisations',              required: false),
    _Step(icon: Icons.access_time,       label: 'Disponibilités',        subtitle: 'Définissez vos créneaux de travail',                  required: true),
    _Step(icon: Icons.person_outline,    label: 'Photo de profil',       subtitle: 'Complétez votre profil professionnel',                required: false),
    _Step(icon: Icons.description,       label: 'Conditions de service', subtitle: 'Définissez vos conditions pour les clients',          required: false),
    _Step(icon: Icons.favorite_outline,  label: 'Confort client',        subtitle: 'Services de confort que vous proposez',               required: false),
    _Step(icon: Icons.workspace_premium, label: 'Abonnement Pro',        subtitle: 'Activez votre abonnement pour toutes les fonctions',  required: true),
    _Step(icon: Icons.credit_card,       label: 'Paiements en ligne',    subtitle: 'Acceptez les acomptes en ligne via Stripe',           required: false),
  ];

  double get _progress => (_currentStep + 1) / _steps.length;
  int    get _percent  => ((_currentStep + 1) / _steps.length * 100).round();

  void _next()      { if (_currentStep < _steps.length - 1) setState(() { _currentStep++; _stepActive = false; }); }
  void _prev()      { if (_currentStep > 0) setState(() { _currentStep--; _stepActive = false; }); }
  void _openStep()  => setState(() => _stepActive = true);
  void _closeStep() => setState(() => _stepActive = false);
  void _goTo(int i) => setState(() { _currentStep = i; _stepActive = true; });

  // ── Fermer = retour au hub prestataire ────────────────────────────
  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/prestataire');
    }
  }

  Widget _buildActiveStep() {
    switch (_currentStep) {
      case 0: return StepServices(onSave: _closeStep, onCancel: _closeStep);
      case 1: return StepRealisations(onSave: _closeStep, onCancel: _closeStep);
      case 2: return StepDisponibilites(onSave: _closeStep, onCancel: _closeStep);
      case 3: return StepPhotoProfil(onSave: _closeStep, onCancel: _closeStep);
      case 4: return StepConditionsService(onSave: _closeStep, onCancel: _closeStep);
      case 5: return StepConfortClient(onSave: _closeStep, onCancel: _closeStep);
      case 6: return StepAbonnementPro(onNext: _next, onClose: _closeStep);
      case 7: return StepPaiements(onNext: _finishOnboarding, onClose: _closeStep);
      default: return const SizedBox();
    }
  }

  // ── Fin onboarding → hub ──────────────────────────────────────────
  void _finishOnboarding() => context.go('/prestataire');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [

          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(
                  child: Text('Configurez votre profil professionnel',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
                ),
                GestureDetector(
                  onTap: _close,
                  child: const Icon(Icons.close, color: _textGrey),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Text('Étape ${_currentStep + 1} sur ${_steps.length}',
                  style: const TextStyle(fontSize: 13, color: _textGrey)),
                const Spacer(),
                Text('$_percent%',
                  style: const TextStyle(fontSize: 13, color: _textGrey)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation(_green),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Complétez votre profil pour commencer à recevoir des réservations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: _green, height: 1.4)),
              ),
              const SizedBox(height: 12),
            ]),
          ),

          // ── Contenu ───────────────────────────────────────────────────
          Expanded(
            child: _stepActive
              ? SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildActiveStep(),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(children: [

                    // Carte étape active (cliquable)
                    GestureDetector(
                      onTap: _openStep,
                      child: _StepCard(step: _steps[_currentStep]),
                    ),
                    const SizedBox(height: 20),

                    // Titre liste
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Aperçu des étapes',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
                    ),
                    const SizedBox(height: 10),

                    // Liste des étapes
                    ..._steps.asMap().entries.map((e) => _StepListItem(
                      step: e.value,
                      index: e.key,
                      current: _currentStep,
                      onTap: () => _goTo(e.key),
                    )),
                    const SizedBox(height: 80),
                  ]),
                ),
          ),

          // ── Navigation bas ────────────────────────────────────────────
          if (!_stepActive)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF0F0F0)))),
              child: Column(children: [
                Row(children: [
                  if (_currentStep > 0)
                    OutlinedButton.icon(
                      onPressed: _prev,
                      icon: const Icon(Icons.chevron_left, size: 18, color: _green),
                      label: const Text('Précédent', style: TextStyle(color: _green)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _green),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                    )
                  else
                    const SizedBox(),
                  const Spacer(),
                  if (_currentStep < _steps.length - 1)
                    OutlinedButton.icon(
                      onPressed: _next,
                      icon: const Text('Suivant', style: TextStyle(color: _textGrey)),
                      label: const Icon(Icons.chevron_right, size: 18, color: _textGrey),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                    )
                  else
                    // Dernière étape → bouton terminer
                    ElevatedButton.icon(
                      onPressed: _finishOnboarding,
                      icon: const Icon(Icons.check, color: Colors.white, size: 18),
                      label: const Text('Terminer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        elevation: 0,
                      ),
                    ),
                ]),
                const SizedBox(height: 6),
                const Text('Cliquez sur l\'étape ci-dessus pour la configurer',
                  style: TextStyle(fontSize: 12, color: _textGrey)),
                const SizedBox(height: 8),
              ]),
            ),
        ]),
      ),
    );
  }
}

// ── Modèle ────────────────────────────────────────────────────────────────────
class _Step {
  final IconData icon;
  final String label, subtitle;
  final bool required;
  _Step({required this.icon, required this.label, required this.subtitle, required this.required});
}

// ── Carte étape active ────────────────────────────────────────────────────────
class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});
  final _Step step;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFF0F0F0)),
      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: Column(children: [
      Container(
        width: 64, height: 64,
        decoration: const BoxDecoration(color: _greenLight, shape: BoxShape.circle),
        child: Icon(step.icon, color: _green, size: 30),
      ),
      const SizedBox(height: 14),
      Text(step.label,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textDark)),
      const SizedBox(height: 6),
      Text(step.subtitle, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: _textGrey)),
      if (step.required) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(50)),
          child: const Text('Étape obligatoire',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
        ),
      ],
      const SizedBox(height: 12),
      const Text('Touchez pour configurer',
        style: TextStyle(fontSize: 14, color: _green, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ── Item liste étapes ─────────────────────────────────────────────────────────
class _StepListItem extends StatelessWidget {
  const _StepListItem({
    required this.step,
    required this.index,
    required this.current,
    required this.onTap,
  });
  final _Step step;
  final int index, current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? _greenLight : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: isActive ? _green : const Color(0xFFF0F0F0)),
        ),
        child: Row(children: [
          Icon(step.icon, color: isActive ? _green : _textGrey, size: 20),
          const SizedBox(width: 12),
          Text(step.label, style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? _textDark : _textGrey,
          )),
        ]),
      ),
    );
  }
}