import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_widgets.dart';
const _gold      = Color(0xFFC4956A);
const _goldLight = Color(0xFFEDE0CC);
const _goldDark  = Color(0xFF8B6340);
const _bg        = Color(0xFFF2EBE0);
const _textDark  = Color(0xFF2C1810);
const _textGrey  = Color(0xFF9E8878);

const _providerTypes = [
  {'key': 'hairdresser', 'label': 'Coiffeur(se)',       'icon': Icons.content_cut_rounded},
  {'key': 'makeup',      'label': 'Maquilleur(se)',      'icon': Icons.face_retouching_natural},
  {'key': 'manicure',    'label': 'Manucure / Pédicure', 'icon': Icons.back_hand_outlined},
];

const _workLocations = [
  {'key': 'home',   'label': 'À mon salon / chez moi', 'icon': Icons.home_rounded},
  {'key': 'client', 'label': 'Chez le client',          'icon': Icons.directions_car_rounded},
  {'key': 'both',   'label': 'Les deux',                'icon': Icons.swap_horiz_rounded},
];

class RegisterProviderPage extends StatefulWidget {
  const RegisterProviderPage({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    this.formEnabled = true,
    this.isLoading = false,
    this.submitError,
  });

  final TextEditingController emailController, passwordController;
  final VoidCallback onSubmit;
  final bool formEnabled, isLoading;
  final String? submitError;

  @override
  State<RegisterProviderPage> createState() => _RegisterProviderPageState();
}

class _RegisterProviderPageState extends State<RegisterProviderPage> {
  final _firstCtrl  = TextEditingController();
  final _lastCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _villeCtrl  = TextEditingController();
  final _expCtrl    = TextEditingController();
  final _bioCtrl    = TextEditingController();
  bool _showPass    = false;
  bool _acceptCGU   = false;
  String _type      = 'hairdresser';
  String _location  = 'home';

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose(); _phoneCtrl.dispose();
    _villeCtrl.dispose(); _expCtrl.dispose(); _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w   = MediaQuery.of(context).size.width;
    final rem = w / 100;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: Column(children: [

        // Header
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(rem * 4, rem * 3.5, rem * 4, rem * 3.5),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: rem * 9, height: rem * 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _goldLight)),
                child: Icon(Icons.arrow_back_rounded, color: _textDark, size: rem * 5))),
            SizedBox(width: rem * 3),
            Text('Espace Prestataire', style: TextStyle(
              fontSize: rem * 4.5, fontWeight: FontWeight.w800, color: _textDark)),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(rem * 5),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Badge
              Container(
                padding: EdgeInsets.all(rem * 4),
                decoration: BoxDecoration(
                  color: _goldLight,
                  borderRadius: BorderRadius.circular(rem * 4),
                  border: Border.all(color: _gold.withOpacity(0.3))),
                child: Row(children: [
                  Container(
                    width: rem * 12, height: rem * 12,
                    decoration: BoxDecoration(color: _gold, shape: BoxShape.circle),
                    child: Icon(Icons.content_cut_rounded, color: Colors.white, size: rem * 6.5)),
                  SizedBox(width: rem * 3),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Espace Pro', style: TextStyle(
                      fontSize: rem * 4, fontWeight: FontWeight.w800, color: _textDark)),
                    Text('Développez votre activité beauté', style: TextStyle(
                      fontSize: rem * 3, color: _goldDark)),
                  ])),
                ])),
              SizedBox(height: rem * 5),

              // Section identité
              _Section(label: 'Identité', icon: Icons.person_rounded, rem: rem),
              Row(children: [
                Expanded(child: _F(label: 'Prénom *', ctrl: _firstCtrl, hint: 'Votre prénom', rem: rem)),
                SizedBox(width: rem * 3),
                Expanded(child: _F(label: 'Nom *', ctrl: _lastCtrl, hint: 'Votre nom', rem: rem)),
              ]),
              _F(label: 'Téléphone *', ctrl: _phoneCtrl, hint: '+33 6 00 00 00 00', rem: rem, type: TextInputType.phone),
              _F(label: 'Ville *', ctrl: _villeCtrl, hint: 'Paris, Lyon…', rem: rem),
              SizedBox(height: rem * 2),

              // Section activité
              _Section(label: 'Activité professionnelle', icon: Icons.work_outline_rounded, rem: rem),
              Text('Votre spécialité *', style: TextStyle(
                fontSize: rem * 3.8, fontWeight: FontWeight.w600, color: _textDark)),
              SizedBox(height: rem * 2),
              ..._providerTypes.map((pt) => _ChoiceBtn(
                icon: pt['icon'] as IconData,
                label: pt['label'] as String,
                active: _type == pt['key'],
                rem: rem,
                onTap: () => setState(() => _type = pt['key'] as String))),
              SizedBox(height: rem * 3),

              Text('Où travaillez-vous ? *', style: TextStyle(
                fontSize: rem * 3.8, fontWeight: FontWeight.w600, color: _textDark)),
              SizedBox(height: rem * 2),
              ..._workLocations.map((wl) => _ChoiceBtn(
                icon: wl['icon'] as IconData,
                label: wl['label'] as String,
                active: _location == wl['key'],
                rem: rem,
                onTap: () => setState(() => _location = wl['key'] as String))),
              SizedBox(height: rem * 3),

              // Section profil
              _Section(label: 'Profil pro', icon: Icons.badge_outlined, rem: rem),
              _F(label: "Années d'expérience", ctrl: _expCtrl,
                hint: 'Ex : 5 ans en coiffure afro', rem: rem),
              _Label(text: 'Bio / Présentation *', rem: rem),
              TextField(
                controller: _bioCtrl, maxLines: 4,
                style: TextStyle(fontSize: rem * 3.8, color: _textDark),
                decoration: _deco('Parlez de vous, votre style, vos techniques…', rem).copyWith(
                  contentPadding: EdgeInsets.all(rem * 3.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(rem * 3),
                    borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(rem * 3),
                    borderSide: const BorderSide(color: Color(0xFFEDE0CC))),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(rem * 3),
                    borderSide: BorderSide(color: _gold, width: 2)))),
              SizedBox(height: rem * 5),

              // Section compte
              _Section(label: 'Compte', icon: Icons.lock_outline_rounded, rem: rem),
              _Label(text: 'Email *', rem: rem),
              _TF(ctrl: widget.emailController, hint: 'votre@email.com',
                enabled: widget.formEnabled, rem: rem, type: TextInputType.emailAddress),
              SizedBox(height: rem * 3.5),

              _Label(text: 'Mot de passe *', rem: rem),
              TextField(
                controller: widget.passwordController,
                enabled: widget.formEnabled,
                obscureText: !_showPass,
                style: TextStyle(fontSize: rem * 3.8, color: _textDark),
                decoration: _deco('••••••••', rem).copyWith(
                  suffixIcon: IconButton(
                    icon: Text(_showPass ? '🙈' : '👁', style: TextStyle(fontSize: rem * 4.5)),
                    onPressed: () => setState(() => _showPass = !_showPass)))),
              SizedBox(height: rem * 5),

              // CGU
              GestureDetector(
                onTap: () => setState(() => _acceptCGU = !_acceptCGU),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: rem * 6, height: rem * 6,
                    decoration: BoxDecoration(
                      color: _acceptCGU ? _gold : Colors.white,
                      borderRadius: BorderRadius.circular(rem * 1.5),
                      border: Border.all(
                        color: _acceptCGU ? _gold : const Color(0xFFEDE0CC), width: 1.5)),
                    child: _acceptCGU
                      ? Icon(Icons.check_rounded, color: Colors.white, size: rem * 4)
                      : null),
                  SizedBox(width: rem * 3),
                  Expanded(child: RichText(text: TextSpan(
                    style: TextStyle(fontSize: rem * 3.2, color: _textGrey, height: 1.5),
                    children: [
                      const TextSpan(text: "J'accepte les "),
                      TextSpan(
                        text: "conditions générales d'utilisation",
                        style: TextStyle(
                          color: _gold, fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => launchUrl(Uri.parse('https://madbeauty.fr/cgu'))),
                    ]))),
                ])),
              SizedBox(height: rem * 4),

              if (widget.submitError != null) ...[
                Container(
                  padding: EdgeInsets.all(rem * 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(rem * 2.5)),
                  child: Row(children: [
                    Icon(Icons.error_outline, color: Colors.red, size: rem * 4.5),
                    SizedBox(width: rem * 2),
                    Expanded(child: Text(widget.submitError!, style: TextStyle(
                      color: Colors.red, fontSize: rem * 3))),
                  ])),
                SizedBox(height: rem * 3),
              ],

              // Bouton
              GestureDetector(
                onTap: (widget.formEnabled && !widget.isLoading && _acceptCGU)
                  ? widget.onSubmit : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: rem * 4),
                  decoration: BoxDecoration(
                    color: _acceptCGU ? _gold : _goldLight,
                    borderRadius: BorderRadius.circular(rem * 8),
                    boxShadow: _acceptCGU ? [BoxShadow(
                      color: _gold.withOpacity(0.4),
                      blurRadius: 12, offset: const Offset(0, 5))] : null),
                  child: Center(child: widget.isLoading
                    ? SizedBox(width: rem * 5, height: rem * 5,
                        child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: rem * 5.5),
                        SizedBox(width: rem * 2),
                        Text('Créer mon espace Pro', style: TextStyle(
                          color: Colors.white, fontSize: rem * 4, fontWeight: FontWeight.w700)),
                      ])))),
              SizedBox(height: rem * 8),
            ]),
          ),
        ),
      ])),
    );
  }
}

// ── Widgets partagés ──────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.icon, required this.rem});
  final String label; final IconData icon; final double rem;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: rem * 3),
    child: Row(children: [
      Container(
        width: rem * 8, height: rem * 8,
        decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
        child: Icon(icon, color: _gold, size: rem * 4.5)),
      SizedBox(width: rem * 2.5),
      Text(label, style: TextStyle(
        fontSize: rem * 3.8, fontWeight: FontWeight.w700, color: _goldDark)),
    ]));
}

class _ChoiceBtn extends StatelessWidget {
  const _ChoiceBtn({required this.icon, required this.label, required this.active,
    required this.onTap, required this.rem});
  final IconData icon; final String label; final bool active;
  final VoidCallback onTap; final double rem;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: rem * 2),
      padding: EdgeInsets.symmetric(horizontal: rem * 4, vertical: rem * 3.5),
      decoration: BoxDecoration(
        color: active ? _goldLight : Colors.white,
        borderRadius: BorderRadius.circular(rem * 3.5),
        border: Border.all(
          color: active ? _gold : const Color(0xFFEDE0CC),
          width: active ? 2 : 1)),
      child: Row(children: [
        Container(
          width: rem * 9, height: rem * 9,
          decoration: BoxDecoration(
            color: active ? _gold : const Color(0xFFF5F0EA),
            shape: BoxShape.circle),
          child: Icon(icon, color: active ? Colors.white : _textGrey, size: rem * 4.5)),
        SizedBox(width: rem * 3),
        Expanded(child: Text(label, style: TextStyle(
          fontSize: rem * 3.8,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? _goldDark : _textGrey))),
        if (active) Icon(Icons.check_circle_rounded, color: _gold, size: rem * 5.5),
      ])));
}