import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

const _green      = Color(0xFF2D7A4F);
const _greenLight = Color(0xFFE8F5EE);
const _greyBg     = Color(0xFFF2F2F7);
const _textDark   = Color(0xFF1A1A1A);
const _textGrey   = Color(0xFF8E8E93);
const _white      = Colors.white;

const _providerTypes = [
  {'key': 'hairdresser', 'label': 'Coiffeur(se)',       'icon': '✂️'},
  {'key': 'makeup',      'label': 'Maquilleur(se)',      'icon': '💄'},
  {'key': 'manicure',    'label': 'Manucure / Pédicure', 'icon': '💅'},
];

const _workLocations = [
  {'key': 'home',   'label': 'À mon salon / chez moi', 'icon': '🏠'},
  {'key': 'client', 'label': 'Chez le client',          'icon': '🚗'},
  {'key': 'both',   'label': 'Les deux',                'icon': '🔄'},
];

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.onBack,
    required this.onPasswordFieldSubmitted,
    this.showSupabaseConfigCard = false,
    this.emailError,
    this.passwordError,
    this.submitError,
    this.isLoading = false,
    this.formEnabled = true,
    // 👇 NOUVEAUX PARAMÈTRES
    this.onRegisterAsProvider,
    this.onRegisterAsClient,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final VoidCallback onPasswordFieldSubmitted;
  final bool showSupabaseConfigCard;
  final String? emailError;
  final String? passwordError;
  final String? submitError;
  final bool isLoading;
  final bool formEnabled;

  /// Appelé quand inscription prestataire réussie → navigue vers onboarding
  final VoidCallback? onRegisterAsProvider;
  /// Appelé quand inscription client réussie → navigue vers accueil client
  final VoidCallback? onRegisterAsClient;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _userType     = 'client';
  String _authMode     = 'login';
  bool   _showPass     = false;
  bool   _acceptedCGU  = false;
  String _providerType = 'hairdresser';
  String _workLocation = 'home';

  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _cityCtrl       = TextEditingController();
  final _addressCtrl    = TextEditingController();
  final _bioCtrl        = TextEditingController();
  final _experienceCtrl = TextEditingController();

  bool get _isProvider => _userType == 'provider';
  bool get _isLogin    => _authMode  == 'login';

  @override
  void dispose() {
    _firstNameCtrl.dispose(); _lastNameCtrl.dispose();
    _phoneCtrl.dispose(); _cityCtrl.dispose();
    _addressCtrl.dispose(); _bioCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  // Appelé quand l'utilisateur appuie sur le bouton principal
  void _handleSubmit() {
    if (!_isLogin) {
      // Inscription
      if (_isProvider) {
        widget.onRegisterAsProvider?.call();
      } else {
        widget.onRegisterAsClient?.call();
      }
    } else {
      // Connexion → login_route gère la redirection selon le rôle
      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Center(
                child: Text('Bienvenue',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: _textDark)),
              ),
              const SizedBox(height: 28),

              if (widget.showSupabaseConfigCard) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD700)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFB8860B), size: 20),
                    SizedBox(width: 10),
                    Expanded(child: Text('Supabase non configuré.',
                      style: TextStyle(color: Color(0xFF7A5800), fontSize: 13))),
                  ]),
                ),
                const SizedBox(height: 20),
              ],

              // Toggle Client / Prestataire
              Row(children: [
                _RoleButton(label: '👥  Client',      type: 'client',   current: _userType, onTap: (v) => setState(() => _userType = v)),
                const SizedBox(width: 12),
                _RoleButton(label: '✂️  Prestataire', type: 'provider', current: _userType, onTap: (v) => setState(() => _userType = v)),
              ]),
              const SizedBox(height: 16),

              // Toggle Connexion / Inscription
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: _greyBg, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  _ModeButton(label: 'Connexion',   mode: 'login',    current: _authMode, onTap: (v) => setState(() => _authMode = v)),
                  _ModeButton(label: 'Inscription', mode: 'register', current: _authMode, onTap: (v) => setState(() => _authMode = v)),
                ]),
              ),
              const SizedBox(height: 20),

              // Carte formulaire
              Container(
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEBEBEB)),
                  boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 2))],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Text(
                    '${_isLogin ? "Se connecter" : "S\'inscrire"} – ${_isProvider ? "Prestataire Pro" : "Client"}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isLogin ? 'Accédez à votre espace personnel'
                      : _isProvider ? 'Créez votre espace professionnel'
                      : 'Créez votre compte gratuitement',
                    style: const TextStyle(fontSize: 14, color: _textGrey),
                  ),
                  const SizedBox(height: 22),

                  if (!_isLogin) ...[
                    _SectionLabel(text: '👤 Identité'),
                    _Field(label: 'Prénom *',  ctrl: _firstNameCtrl,  placeholder: 'Votre prénom'),
                    _Field(label: 'Nom *',     ctrl: _lastNameCtrl,   placeholder: 'Votre nom'),
                    _Field(label: 'Téléphone', ctrl: _phoneCtrl,      placeholder: '+33 6 00 00 00 00', type: TextInputType.phone, caps: TextCapitalization.none),
                    _SectionLabel(text: '📍 Localisation'),
                    _Field(label: 'Ville *',   ctrl: _cityCtrl,       placeholder: 'Paris, Lyon…'),
                    _Field(label: 'Adresse',   ctrl: _addressCtrl,    placeholder: '12 rue des Lilas (facultatif)'),

                    if (_isProvider) ...[
                      _SectionLabel(text: '💼 Activité professionnelle'),
                      const Text('Spécialité *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
                      const SizedBox(height: 8),
                      ..._providerTypes.map((pt) => _ChoiceButton(
                        icon: pt['icon']!, label: pt['label']!,
                        active: _providerType == pt['key'],
                        onTap: () => setState(() => _providerType = pt['key']!),
                      )),
                      const SizedBox(height: 12),
                      const Text('Où travaillez-vous ? *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
                      const SizedBox(height: 8),
                      ..._workLocations.map((wl) => _ChoiceButton(
                        icon: wl['icon']!, label: wl['label']!,
                        active: _workLocation == wl['key'],
                        onTap: () => setState(() => _workLocation = wl['key']!),
                      )),
                      _SectionLabel(text: '📋 Profil pro'),
                      _Field(label: "Années d'expérience", ctrl: _experienceCtrl, placeholder: 'Ex : 5 ans en coiffure afro'),
                      const Text('Bio / Présentation *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _bioCtrl,
                        maxLines: 4,
                        enabled: widget.formEnabled,
                        style: const TextStyle(fontSize: 15, color: _textDark),
                        decoration: _inputDeco('Parlez de vous, votre style, vos techniques…'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],

                  const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: widget.emailController,
                    enabled: widget.formEnabled,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 15, color: _textDark),
                    decoration: _inputDeco('votre@email.com', error: widget.emailError),
                  ),
                  const SizedBox(height: 16),

                  const Text('Mot de passe', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: widget.passwordController,
                    enabled: widget.formEnabled,
                    obscureText: !_showPass,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => widget.onPasswordFieldSubmitted(),
                    style: const TextStyle(fontSize: 15, color: _textDark),
                    decoration: _inputDeco('••••••••', error: widget.passwordError).copyWith(
                      suffixIcon: IconButton(
                        icon: Text(_showPass ? '🙈' : '👁', style: const TextStyle(fontSize: 18)),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (!_isLogin) ...[
                    GestureDetector(
                      onTap: () => setState(() => _acceptedCGU = !_acceptedCGU),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: _acceptedCGU ? _green : _white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _acceptedCGU ? _green : const Color(0xFFE0E0E0), width: 1.5),
                          ),
                          child: _acceptedCGU ? const Icon(Icons.check, color: _white, size: 14) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 13, color: _textGrey, height: 1.5),
                              children: [
                                const TextSpan(text: "J'accepte les "),
                                TextSpan(
                                  text: "conditions générales d'utilisation",
                                  style: const TextStyle(color: _green, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => launchUrl(Uri.parse('https://madbeauty.fr/cgu')),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 18),
                  ],

                  if (widget.submitError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFFEEEE), borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: Color(0xFFCC3333), size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(widget.submitError!,
                          style: const TextStyle(color: Color(0xFFCC3333), fontSize: 13))),
                      ]),
                    ),
                    const SizedBox(height: 14),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (widget.formEnabled && !widget.isLoading && (_isLogin || _acceptedCGU))
                        ? _handleSubmit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: _white,
                        disabledBackgroundColor: const Color(0xFFA0C4B0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        elevation: 0,
                      ),
                      child: widget.isLoading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: _white))
                        : Text(
                            _isLogin ? 'Se connecter'
                              : _isProvider ? 'Créer mon espace Pro'
                              : 'Créer mon compte',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                    ),
                  ),

                  if (_isLogin) ...[
                    const SizedBox(height: 14),
                    Center(
                      child: TextButton(
                        onPressed: widget.formEnabled ? () {} : null,
                        child: const Text('Mot de passe oublié ?',
                          style: TextStyle(color: _green, fontSize: 14,
                            fontWeight: FontWeight.w500, decoration: TextDecoration.underline)),
                      ),
                    ),
                  ],
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDeco(String hint, {String? error}) => InputDecoration(
  hintText: hint, hintStyle: const TextStyle(color: _textGrey),
  errorText: error, filled: true, fillColor: _white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
  border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _green, width: 2)),
  errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCC3333))),
);

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 12),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _green, letterSpacing: 0.8)),
  );
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.ctrl, required this.placeholder,
    this.type = TextInputType.text, this.caps = TextCapitalization.words});
  final String label, placeholder;
  final TextEditingController ctrl;
  final TextInputType type;
  final TextCapitalization caps;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark)),
      const SizedBox(height: 8),
      TextField(controller: ctrl, keyboardType: type, textCapitalization: caps,
        style: const TextStyle(fontSize: 15, color: _textDark),
        decoration: _inputDeco(placeholder)),
      const SizedBox(height: 16),
    ],
  );
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({required this.icon, required this.label, required this.active, required this.onTap});
  final String icon, label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: active ? _greenLight : _white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? _green : const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(
          fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? _green : _textGrey))),
        if (active) const Text('✓', style: TextStyle(fontSize: 16, color: _green, fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({required this.label, required this.type, required this.current, required this.onTap});
  final String label, type, current;
  final ValueChanged<String> onTap;
  @override
  Widget build(BuildContext context) {
    final active = current == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? _green : _white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: _green, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: active ? _white : _green)),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.label, required this.mode, required this.current, required this.onTap});
  final String label, mode, current;
  final ValueChanged<String> onTap;
  @override
  Widget build(BuildContext context) {
    final active = current == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? _green : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: active ? _white : _textGrey)),
        ),
      ),
    );
  }
}













// import 'package:flutter/material.dart';

// import '../../../../core/constants/app_strings.dart';

// /// Page de connexion : mise en page uniquement (aucune règle métier).
// class LoginPage extends StatelessWidget {
//   const LoginPage({
//     super.key,
//     required this.showSupabaseConfigCard,
//     required this.emailController,
//     required this.passwordController,
//     required this.emailError,
//     required this.passwordError,
//     required this.submitError,
//     required this.isLoading,
//     required this.formEnabled,
//     required this.onBack,
//     required this.onSubmit,
//     required this.onPasswordFieldSubmitted,
//   });

//   final bool showSupabaseConfigCard;
//   final TextEditingController emailController;
//   final TextEditingController passwordController;
//   final String? emailError;
//   final String? passwordError;
//   final String? submitError;
//   final bool isLoading;
//   final bool formEnabled;
//   final VoidCallback onBack;
//   final VoidCallback onSubmit;
//   final VoidCallback onPasswordFieldSubmitted;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(AppStrings.loginTitle),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: isLoading ? null : onBack,
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 AppStrings.loginDescription,
//                 style: Theme.of(context).textTheme.bodyMedium,
//               ),
//               const SizedBox(height: 24),
//               if (showSupabaseConfigCard) ...[
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           AppStrings.supabaseMissingTitle,
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           AppStrings.supabaseMissingBody,
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//               ],
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   TextField(
//                     controller: emailController,
//                     enabled: formEnabled,
//                     keyboardType: TextInputType.emailAddress,
//                     autocorrect: false,
//                     textInputAction: TextInputAction.next,
//                     decoration: InputDecoration(
//                       labelText: AppStrings.loginFieldEmail,
//                       errorText: emailError,
//                       border: const OutlineInputBorder(),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: passwordController,
//                     enabled: formEnabled,
//                     obscureText: true,
//                     textInputAction: TextInputAction.done,
//                     onSubmitted: (_) => onPasswordFieldSubmitted(),
//                     decoration: InputDecoration(
//                       labelText: AppStrings.loginFieldPassword,
//                       errorText: passwordError,
//                       border: const OutlineInputBorder(),
//                     ),
//                   ),
//                   if (submitError != null) ...[
//                     const SizedBox(height: 16),
//                     Material(
//                       color: Theme.of(context).colorScheme.errorContainer,
//                       borderRadius: BorderRadius.circular(12),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Text(
//                           submitError!,
//                           style:
//                               Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                     color: Theme.of(context)
//                                         .colorScheme
//                                         .onErrorContainer,
//                                   ),
//                         ),
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 24),
//                   FilledButton(
//                     onPressed: !formEnabled || isLoading ? null : onSubmit,
//                     child: isLoading
//                         ? const SizedBox(
//                             height: 22,
//                             width: 22,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : Text(AppStrings.loginActionSubmit),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
