import '../../../../core/models/user_role.dart';

/// Brouillon du formulaire d’inscription (persistance locale).
class RegisterWizardDraft {
  const RegisterWizardDraft({
    required this.step,
    required this.prenom,
    required this.nom,
    required this.phone,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.adresse,
    required this.salon,
    required this.ville,
    required this.bio,
    required this.signedUpViaOAuth,
    required this.phoneRequiredOnExtras,
    this.role,
  });

  final int step;
  final String prenom;
  final String nom;
  final String phone;
  final String email;
  final String password;
  final String confirmPassword;
  final String adresse;
  final String salon;
  final String ville;
  final String bio;
  final bool signedUpViaOAuth;
  final bool phoneRequiredOnExtras;
  final UserRole? role;

  bool get isActive =>
      step > 0 ||
      prenom.isNotEmpty ||
      nom.isNotEmpty ||
      phone.isNotEmpty ||
      email.isNotEmpty ||
      password.isNotEmpty ||
      role != null ||
      salon.isNotEmpty ||
      ville.isNotEmpty ||
      adresse.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'step': step,
        'prenom': prenom,
        'nom': nom,
        'phone': phone,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'adresse': adresse,
        'salon': salon,
        'ville': ville,
        'bio': bio,
        'signedUpViaOAuth': signedUpViaOAuth,
        'phoneRequiredOnExtras': phoneRequiredOnExtras,
        'role': role?.name,
        'v': 1,
      };

  static RegisterWizardDraft? fromJson(Map<String, dynamic> json) {
    if (json['v'] != 1) return null;
    final step = json['step'];
    if (step is! int || step < 0 || step > 2) return null;

    UserRole? role;
    final roleRaw = json['role'];
    if (roleRaw == 'client') {
      role = UserRole.client;
    } else if (roleRaw == 'prestataire') {
      role = UserRole.prestataire;
    }

    return RegisterWizardDraft(
      step: step,
      prenom: json['prenom'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      confirmPassword: json['confirmPassword'] as String? ?? '',
      adresse: json['adresse'] as String? ?? '',
      salon: json['salon'] as String? ?? '',
      ville: json['ville'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      signedUpViaOAuth: json['signedUpViaOAuth'] as bool? ?? false,
      phoneRequiredOnExtras: json['phoneRequiredOnExtras'] as bool? ?? false,
      role: role,
    );
  }
}
