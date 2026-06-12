import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/user_role.dart';
import '../../../../shared/utils/phone_number_utils.dart';
import '../logic/register_wizard_constants.dart';
import '../logic/register_wizard_draft.dart';
import '../logic/register_wizard_validation.dart';
import '../storage/register_wizard_draft_store.dart';

/// État du formulaire d'inscription (3 étapes).
class RegisterWizardFormController extends ChangeNotifier {
  RegisterWizardFormController() {
    final draft = RegisterWizardDraftStore.instance.read();
    if (draft != null) {
      applyDraft(draft);
      if (draft.pendingGoogleSignIn) {
        googleLaunched = true;
      }
    }
    attachAutosave();
  }

  int step = 0;
  Timer? saveDebounce;
  bool persistDraftOnDispose = true;

  final prenom = TextEditingController();
  final nom = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  final adresse = TextEditingController();
  final salon = TextEditingController();
  final nomAffiche = TextEditingController();
  final codePostal = TextEditingController();
  final description = TextEditingController();
  final ville = TextEditingController();
  final bio = TextEditingController();

  UserRole? roleChoice;
  String phoneDialCode = '+33';
  String? error;
  String? prenomError;
  String? nomError;
  String? phoneError;
  String? emailError;
  String? passwordError;
  String? confirmError;
  String? salonError;
  String? villeError;
  bool loading = false;
  bool signedUpViaOAuth = false;
  bool googleLaunched = false;
  bool googleSigningIn = false;
  bool pendingGoogleSignIn = false;
  bool phoneRequiredOnExtras = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool pendingEmailVerification = false;

  bool get isPresta => roleChoice == UserRole.prestataire;

  String get phoneE164 => PhoneNumberUtils.toE164(
        dialCode: phoneDialCode,
        local: phone.text,
      );

  /// Mot de passe exclu : jamais persisté sur disque.
  List<TextEditingController> get _autosaveControllers => [
    prenom,
    nom,
    phone,
    email,
    adresse,
    salon,
    ville,
    bio,
  ];

  void attachAutosave() {
    void scheduleSave() {
      saveDebounce?.cancel();
      saveDebounce = Timer(
        const Duration(milliseconds: RegisterWizardConstants.autosaveDebounceMs),
        () => unawaited(persistDraft()),
      );
    }

    for (final controller in _autosaveControllers) {
      controller.addListener(scheduleSave);
    }
  }

  void applyDraft(RegisterWizardDraft draft) {
    step = draft.step.clamp(0, 2);
    prenom.text = draft.prenom;
    nom.text = draft.nom;
    phone.text = draft.phone;
    email.text = draft.email;
    adresse.text = draft.adresse;
    salon.text = draft.salon;
    nomAffiche.text = draft.nomAffiche;
    codePostal.text = draft.codePostal;
    description.text = draft.description;
    ville.text = draft.ville;
    bio.text = draft.bio;
    phoneDialCode = draft.phoneDialCode;
    roleChoice = draft.role;
    signedUpViaOAuth = draft.signedUpViaOAuth;
    pendingGoogleSignIn = draft.pendingGoogleSignIn;
    phoneRequiredOnExtras = draft.phoneRequiredOnExtras;
    pendingEmailVerification = draft.pendingEmailVerification;
    notifyListeners();
  }

  RegisterWizardDraft currentDraft() => RegisterWizardDraft(
        step: step,
        prenom: prenom.text,
        nom: nom.text,
        phone: phone.text,
        phoneDialCode: phoneDialCode,
        email: email.text,
        adresse: adresse.text,
        salon: salon.text,
        nomAffiche: nomAffiche.text,
        codePostal: codePostal.text,
        description: description.text,
        ville: ville.text,
        bio: bio.text,
        signedUpViaOAuth: signedUpViaOAuth,
        pendingGoogleSignIn: pendingGoogleSignIn || googleLaunched,
        phoneRequiredOnExtras: phoneRequiredOnExtras,
        pendingEmailVerification: pendingEmailVerification,
        role: roleChoice,
      );

  Future<void> persistDraft({
    bool? pendingEmailVerification,
    bool? pendingGoogleSignIn,
    int? step,
  }) async {
    if (!persistDraftOnDispose) return;
    if (pendingEmailVerification != null) {
      this.pendingEmailVerification = pendingEmailVerification;
    }
    if (pendingGoogleSignIn != null) {
      this.pendingGoogleSignIn = pendingGoogleSignIn;
    }
    if (step != null) {
      this.step = step.clamp(0, 2);
    }
    await RegisterWizardDraftStore.instance.save(currentDraft());
    notifyListeners();
  }

  Future<void> clearDraft() => RegisterWizardDraftStore.instance.clear();

  @override
  void dispose() {
    saveDebounce?.cancel();
    if (persistDraftOnDispose) {
      unawaited(persistDraft());
    }
    for (final c in [
      prenom,
      nom,
      phone,
      email,
      password,
      confirm,
      adresse,
      salon,
      nomAffiche,
      codePostal,
      description,
      ville,
      bio,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String stepPrimaryLabel() {
    if (step >= 2) {
      return AuthStrings.registerWizardSubmit;
    }
    return AuthStrings.registerWizardNext;
  }

  void hydrateFromOAuthUser(User user) {
    final meta = user.userMetadata;
    final metaPrenom = meta?['prenom'] as String? ?? '';
    final metaNom = meta?['nom'] as String? ?? '';
    final givenName = meta?['given_name'] as String? ?? '';
    final familyName = meta?['family_name'] as String? ?? '';
    final fullName =
        (meta?['full_name'] as String? ?? meta?['name'] as String?)
            ?.trim() ??
        '';

    if (givenName.trim().isNotEmpty) {
      prenom.text = givenName.trim();
    } else if (metaPrenom.trim().isNotEmpty) {
      prenom.text = metaPrenom.trim();
    } else if (fullName.isNotEmpty) {
      final parts = fullName.split(RegExp(r'\s+'));
      prenom.text = parts.first;
      if (parts.length > 1) {
        nom.text = parts.sublist(1).join(' ');
      }
    }

    if (familyName.trim().isNotEmpty) {
      nom.text = familyName.trim();
    } else {
      final trimmedNom = metaNom.trim();
      if (trimmedNom.isNotEmpty) {
        nom.text = trimmedNom;
      }
    }

    final metaPhone = meta?['phone'] as String?;
    if (metaPhone != null && metaPhone.trim().isNotEmpty) {
      final parsed = PhoneNumberUtils.parseStored(metaPhone);
      phoneDialCode = parsed.dialCode;
      phone.text = parsed.local;
    } else {
      phoneRequiredOnExtras = true;
    }

    final userEmail = user.email;
    if (userEmail != null && userEmail.isNotEmpty) {
      email.text = userEmail;
    }

    signedUpViaOAuth = true;
    notifyListeners();
  }

  void clearFieldErrors() {
    prenomError = null;
    nomError = null;
    phoneError = null;
    emailError = null;
    passwordError = null;
    confirmError = null;
    salonError = null;
    villeError = null;
    notifyListeners();
  }

  void applyFieldErrors(RegisterWizardFieldErrors errors) {
    prenomError = errors.prenomError ?? prenomError;
    nomError = errors.nomError ?? nomError;
    phoneError = errors.phoneError ?? phoneError;
    emailError = errors.emailError ?? emailError;
    passwordError = errors.passwordError ?? passwordError;
    confirmError = errors.confirmError ?? confirmError;
    salonError = errors.salonError ?? salonError;
    villeError = errors.villeError ?? villeError;
    if (errors.roleError != null) {
      error = errors.roleError;
    }
    notifyListeners();
  }

  bool validateStep0() {
    final errors = RegisterWizardValidation.validateStep0(
      prenom: prenom.text.trim(),
      nom: nom.text.trim(),
      phone: phone.text,
      dialCode: phoneDialCode,
      email: email.text.trim(),
      password: password.text,
      confirmPassword: confirm.text,
      signedUpViaOAuth: signedUpViaOAuth,
    );
    prenomError = errors.prenomError;
    nomError = errors.nomError;
    phoneError = errors.phoneError;
    emailError = errors.emailError;
    passwordError = errors.passwordError;
    confirmError = errors.confirmError;
    error = null;
    notifyListeners();
    return errors.step0Valid;
  }

  bool validateExtrasStep() {
    final errors = RegisterWizardValidation.validateExtras(
      isPresta: isPresta,
      salon: salon.text.trim(),
      ville: ville.text.trim(),
    );
    salonError = errors.salonError;
    villeError = errors.villeError;
    error = null;
    notifyListeners();
    return errors.extrasValid;
  }

  /// Avance d'une étape. Retourne `false` si validation échoue.
  bool advanceStep() {
    if (step == 0) {
      if (!validateStep0()) return false;
      step = 1;
      error = null;
      clearFieldErrors();
      unawaited(persistDraft());
      notifyListeners();
      return true;
    }

    if (step == 1) {
      final roleErr = RegisterWizardValidation.validateRole(roleChoice);
      if (roleErr != null) {
        error = roleErr;
        notifyListeners();
        return false;
      }
      step = 2;
      error = null;
      clearFieldErrors();
      unawaited(persistDraft());
      notifyListeners();
      return true;
    }

    return false;
  }

  void goToPreviousStep() {
    if (step == 0) return;
    step -= 1;
    error = null;
    clearFieldErrors();
    unawaited(persistDraft());
    notifyListeners();
  }

  void selectRole(UserRole role) {
    roleChoice = role;
    error = null;
    notifyListeners();
    unawaited(persistDraft());
  }

  void clearPrenomError() {
    prenomError = null;
    notifyListeners();
  }

  void clearNomError() {
    nomError = null;
    notifyListeners();
  }

  void clearPhoneError() {
    phoneError = null;
    notifyListeners();
  }

  void clearEmailError() {
    emailError = null;
    notifyListeners();
  }

  void clearPasswordError() {
    passwordError = null;
    notifyListeners();
  }

  void clearConfirmError() {
    confirmError = null;
    notifyListeners();
  }

  void clearSalonError() {
    salonError = null;
    error = null;
    notifyListeners();
  }

  void clearVilleError() {
    villeError = null;
    error = null;
    notifyListeners();
  }

  void setPhoneDialCode(String code) {
    phoneDialCode = code;
    notifyListeners();
    unawaited(persistDraft());
  }

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  void setError(String? message) {
    error = message;
    notifyListeners();
  }

  void setGoogleSigningIn(bool value) {
    googleSigningIn = value;
    notifyListeners();
  }

  void onOAuthConnected() {
    googleLaunched = false;
    pendingGoogleSignIn = false;
    googleSigningIn = false;
    error = null;
    clearFieldErrors();
    notifyListeners();
  }

  void resetGooglePending() {
    googleLaunched = false;
    pendingGoogleSignIn = false;
    notifyListeners();
  }

  /// Efface le mot de passe de la mémoire (jamais écrit sur disque).
  void clearPasswordFields() {
    password.clear();
    confirm.clear();
    passwordError = null;
    confirmError = null;
    notifyListeners();
  }
}
