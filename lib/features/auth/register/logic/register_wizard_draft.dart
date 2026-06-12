import '../../../../core/models/user_role.dart';



/// Brouillon du formulaire d'inscription (persistance locale).

///

/// Le mot de passe n'est jamais persisté (mémoire uniquement, via les controllers).

class RegisterWizardDraft {

  const RegisterWizardDraft({

    required this.step,

    required this.prenom,

    required this.nom,

    required this.phone,

    required this.phoneDialCode,

    required this.email,

    required this.adresse,

    required this.salon,

    required this.nomAffiche,

    required this.codePostal,

    required this.description,

    required this.ville,

    required this.bio,

    required this.signedUpViaOAuth,

    required this.phoneRequiredOnExtras,

    this.pendingEmailVerification = false,

    this.pendingGoogleSignIn = false,

    this.role,

  });



  final int step;

  final String prenom;

  final String nom;

  final String phone;

  final String phoneDialCode;

  final String email;

  final String adresse;

  final String salon;

  final String nomAffiche;

  final String codePostal;

  final String description;

  final String ville;

  final String bio;

  final bool signedUpViaOAuth;

  final bool phoneRequiredOnExtras;



  /// Compte créé, en attente de confirmation e-mail (ne pas afficher « brouillon repris »).

  final bool pendingEmailVerification;



  /// Google OAuth lancé, retour navigateur en attente.

  final bool pendingGoogleSignIn;

  final UserRole? role;



  /// Brouillon actif tant que le wizard n'est pas terminé (y compris après Google).

  bool get isActive =>

      signedUpViaOAuth ||

      pendingGoogleSignIn ||

      step > 0 ||

      prenom.isNotEmpty ||

      nom.isNotEmpty ||

      phone.isNotEmpty ||

      email.isNotEmpty ||

      role != null ||

      salon.isNotEmpty ||

      ville.isNotEmpty ||

      adresse.isNotEmpty;



  /// Afficher la bannière « reprise » (cold start / retour app).

  bool get showResumeBanner =>

      isActive &&

      !pendingEmailVerification &&

      !pendingGoogleSignIn;



  Map<String, dynamic> toJson() => {

        'step': step,

        'prenom': prenom,

        'nom': nom,

        'phone': phone,

        'phoneDialCode': phoneDialCode,

        'email': email,

        'adresse': adresse,

        'salon': salon,

        'nomAffiche': nomAffiche,

        'codePostal': codePostal,

        'description': description,

        'ville': ville,

        'bio': bio,

        'signedUpViaOAuth': signedUpViaOAuth,

        'phoneRequiredOnExtras': phoneRequiredOnExtras,

        'pendingEmailVerification': pendingEmailVerification,

        'pendingGoogleSignIn': pendingGoogleSignIn,

        'role': role?.name,

        'v': 6,

      };



  static RegisterWizardDraft? fromJson(Map<String, dynamic> json) {

    final version = json['v'];

    if (version != 1 &&

        version != 2 &&

        version != 3 &&

        version != 4 &&

        version != 5 &&

        version != 6) {

      return null;

    }

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

      phoneDialCode: json['phoneDialCode'] as String? ?? '+33',

      email: json['email'] as String? ?? '',

      adresse: json['adresse'] as String? ?? '',

      salon: json['salon'] as String? ?? '',

      nomAffiche: json['nomAffiche'] as String? ?? '',

      codePostal: json['codePostal'] as String? ?? '',

      description: json['description'] as String? ?? '',

      ville: json['ville'] as String? ?? '',

      bio: json['bio'] as String? ?? '',

      signedUpViaOAuth: json['signedUpViaOAuth'] as bool? ?? false,

      phoneRequiredOnExtras: json['phoneRequiredOnExtras'] as bool? ?? false,

      pendingEmailVerification:

          json['pendingEmailVerification'] as bool? ?? false,

      pendingGoogleSignIn: json['pendingGoogleSignIn'] as bool? ?? false,

      role: role,

    );

  }



  /// `true` si le JSON stocké contient encore un mot de passe (versions < 6).

  static bool legacyPayloadContainsPassword(Map<String, dynamic> json) =>

      json.containsKey('password') || json.containsKey('confirmPassword');

}


