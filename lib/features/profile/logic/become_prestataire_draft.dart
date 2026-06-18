import 'become_prestataire_hub_draft.dart';
import '../../../core/logic/address/postal_address.dart';

/// Brouillon du parcours « Devenir prestataire » (étapes 1 et 2).
class BecomePrestataireDraft {
  const BecomePrestataireDraft({
    required this.salon,
    required this.ville,
    required this.bio,
    this.codePostal = '',
    this.nomAffiche = '',
    this.description = '',
    this.adresse = '',
    this.voieType = PostalVoieTypes.defaultType,
    this.voieNom = '',
    this.numeroRue = '',
    this.pays = PostalAddress.defaultCountry,
    this.step1Submitted = false,
    this.step2Started = false,
    this.hub,
  });

  final String salon;
  final String ville;
  final String bio;
  final String codePostal;
  final String nomAffiche;
  final String description;
  final String adresse;
  final String voieType;
  final String voieNom;
  final String numeroRue;
  final String pays;
  final bool step1Submitted;
  final bool step2Started;
  final BecomePrestataireHubDraft? hub;

  PostalAddress get postalAddress {
    if (voieNom.trim().isNotEmpty ||
        numeroRue.trim().isNotEmpty ||
        codePostal.trim().isNotEmpty ||
        ville.trim().isNotEmpty) {
      return PostalAddress(
        voieType: voieType,
        voieNom: voieNom,
        numero: numeroRue,
        codePostal: codePostal,
        ville: ville,
        pays: pays,
      );
    }
    if (adresse.trim().isNotEmpty) {
      return PostalAddress.tryParse(adresse);
    }
    return const PostalAddress();
  }

  bool get isActive =>
      step1Submitted ||
      step2Started ||
      (hub?.hasContent ?? false) ||
      salon.trim().isNotEmpty ||
      ville.trim().isNotEmpty ||
      bio.trim().isNotEmpty ||
      codePostal.trim().isNotEmpty ||
      nomAffiche.trim().isNotEmpty ||
      description.trim().isNotEmpty ||
      adresse.trim().isNotEmpty ||
      voieNom.trim().isNotEmpty;

  BecomePrestataireDraft copyWith({
    String? salon,
    String? ville,
    String? bio,
    String? codePostal,
    String? nomAffiche,
    String? description,
    String? adresse,
    String? voieType,
    String? voieNom,
    String? numeroRue,
    String? pays,
    bool? step1Submitted,
    bool? step2Started,
    BecomePrestataireHubDraft? hub,
    bool clearHub = false,
  }) {
    return BecomePrestataireDraft(
      salon: salon ?? this.salon,
      ville: ville ?? this.ville,
      bio: bio ?? this.bio,
      codePostal: codePostal ?? this.codePostal,
      nomAffiche: nomAffiche ?? this.nomAffiche,
      description: description ?? this.description,
      adresse: adresse ?? this.adresse,
      voieType: voieType ?? this.voieType,
      voieNom: voieNom ?? this.voieNom,
      numeroRue: numeroRue ?? this.numeroRue,
      pays: pays ?? this.pays,
      step1Submitted: step1Submitted ?? this.step1Submitted,
      step2Started: step2Started ?? this.step2Started,
      hub: clearHub ? null : (hub ?? this.hub),
    );
  }

  Map<String, dynamic> toJson() => {
        'salon': salon,
        'ville': ville,
        'bio': bio,
        'codePostal': codePostal,
        'nomAffiche': nomAffiche,
        'description': description,
        'adresse': adresse,
        'voieType': voieType,
        'voieNom': voieNom,
        'numeroRue': numeroRue,
        'pays': pays,
        'step1Submitted': step1Submitted,
        'step2Started': step2Started,
        if (hub != null) 'hub': hub!.toJson(),
        'v': 4,
      };

  static BecomePrestataireDraft? fromJson(Map<String, dynamic> json) {
    final version = json['v'];
    if (version != 1 && version != 2 && version != 3 && version != 4) {
      return null;
    }
    return BecomePrestataireDraft(
      salon: json['salon'] as String? ?? '',
      ville: json['ville'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      codePostal: json['codePostal'] as String? ?? '',
      nomAffiche: json['nomAffiche'] as String? ?? '',
      description: json['description'] as String? ?? '',
      adresse: json['adresse'] as String? ?? '',
      voieType: json['voieType'] as String? ?? PostalVoieTypes.defaultType,
      voieNom: json['voieNom'] as String? ?? '',
      numeroRue: json['numeroRue'] as String? ?? '',
      pays: json['pays'] as String? ?? PostalAddress.defaultCountry,
      step1Submitted: json['step1Submitted'] as bool? ?? false,
      step2Started: json['step2Started'] as bool? ?? false,
      hub: version >= 2
          ? BecomePrestataireHubDraft.fromJson(json['hub'])
          : null,
    );
  }
}
