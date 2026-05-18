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

class RegisterClientPage extends StatefulWidget {
  const RegisterClientPage({
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
  State<RegisterClientPage> createState() => _RegisterClientPageState();
}

class _RegisterClientPageState extends State<RegisterClientPage> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _villeCtrl = TextEditingController();
  bool _showPass   = false;
  bool _acceptCGU  = false;

  @override
  void dispose() {
    _firstCtrl.dispose(); _lastCtrl.dispose();
    _phoneCtrl.dispose(); _villeCtrl.dispose();
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
            Text('Créer mon compte', style: TextStyle(
              fontSize: rem * 4.5, fontWeight: FontWeight.w800, color: _textDark)),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(rem * 5),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Badge client
              Container(
                padding: EdgeInsets.all(rem * 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(rem * 4),
                  boxShadow: [BoxShadow(
                    color: _textDark.withOpacity(0.06),
                    blurRadius: 10, offset: const Offset(0, 3))]),
                child: Row(children: [
                  Container(
                    width: rem * 12, height: rem * 12,
                    decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
                    child: Icon(Icons.person_rounded, color: _gold, size: rem * 6.5)),
                  SizedBox(width: rem * 3),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Espace Client', style: TextStyle(
                      fontSize: rem * 4, fontWeight: FontWeight.w800, color: _textDark)),
                    Text('Inscription gratuite', style: TextStyle(
                      fontSize: rem * 3, color: _textGrey)),
                  ])),
                ])),
              SizedBox(height: rem * 5),

              // Prénom / Nom
              Row(children: [
                Expanded(child: _F(label: 'Prénom *', ctrl: _firstCtrl, hint: 'Votre prénom', rem: rem)),
                SizedBox(width: rem * 3),
                Expanded(child: _F(label: 'Nom *', ctrl: _lastCtrl, hint: 'Votre nom', rem: rem)),
              ]),
              _F(label: 'Téléphone', ctrl: _phoneCtrl, hint: '+33 6 00 00 00 00', rem: rem, type: TextInputType.phone),
              _F(label: 'Ville *', ctrl: _villeCtrl, hint: 'Paris, Lyon…', rem: rem),

              // Email
              _Label(text: 'Email *', rem: rem),
              _TF(ctrl: widget.emailController, hint: 'votre@email.com',
                enabled: widget.formEnabled, rem: rem, type: TextInputType.emailAddress),
              SizedBox(height: rem * 3.5),

              // Mot de passe
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
              SizedBox(height: rem * 4),

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
                    : Text('Créer mon compte', style: TextStyle(
                        color: Colors.white, fontSize: rem * 4, fontWeight: FontWeight.w700))))),
              SizedBox(height: rem * 8),
            ]),
          ),
        ),
      ])),
    );
  }
}