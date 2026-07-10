# App Store Connect — textes MadBeauty

Copier-coller dans **App Store Connect** → votre app → **Informations sur l’app** (ou version 1.0.0).

Langue principale : **Français (France)**.

---

## Nom

```
MadBeauty
```

(Si refusé : utiliser un nom unique type `MadBeautyWorld` dans Connect, tout en gardant **MadBeauty** sous l’icône via `Info.plist`.)

---

## Sous-titre (30 caractères max)

```
Beauté afro & réservation
```

---

## Texte promotionnel (170 caractères max, modifiable sans nouvelle version)

```
Réserve ta coiffeuse, ta manucure ou ton maquillage afro en quelques taps. Prestataires : gère ton agenda, ton profil et tes paiements depuis la même app.
```

---

## Description (4 000 caractères max)

```
MadBeauty connecte les clientes aux meilleurs professionnels de la beauté afro : coiffure, tresses, locks, manucure, maquillage et bien plus.

POUR LES CLIENTES
• Découvre des prestataires près de chez toi sur la carte
• Consulte les profils, avis, photos de réalisations et tarifs
• Réserve un créneau en quelques étapes
• Paie en ligne en toute sécurité (Stripe) lorsque le prestataire l’accepte
• Échange avec ton pro via un chat intégré après confirmation
• Reçois des rappels et alertes lorsqu’un créneau se libère
• Parraine tes amies avec ton code personnel

POUR LES PRESTATAIRES
• Crée et complète ton profil professionnel (salon, services, photos)
• Gère ton agenda, tes disponibilités et tes réservations
• Accepte ou refuse les demandes, avec messagerie client
• Encaisse tes prestations via Stripe Connect
• Développe ta visibilité sur la plateforme beauté afro

SÉCURITÉ & CONFIANCE
• Compte sécurisé (e-mail, Google ou Apple)
• Modération des contenus signalés
• Politique de confidentialité accessible dans l’app

MadBeauty : ta beauté, tes racines, ton rendez-vous.
```

---

## Mots-clés (100 caractères max, séparés par des virgules, sans espace après la virgule)

```
beauté,afro,coiffure,réservation,coiffeuse,manucure,maquillage,salon,locks,tresses
```

---

## URL politique de confidentialité

```
https://madbeauty-web.netlify.app/privacy.html
```

## URL sécurité des enfants (Google Play / standards child safety)

```
https://madbeauty-web.netlify.app/child-safety.html
```

Contenu : public 18+, pas de collecte volontaire de données mineurs, droits des parents (RGPD), signalement et modération.

(Site vitrine dans `website/` — voir `website/README.md` pour le déploiement.)

## URL marketing (site vitrine)

```
https://madbeauty-web.netlify.app/
```

## Application web (catalogue / réservation)

```
https://madbeauty-app.netlify.app
```

---

## Catégorie suggérée

- **Principale** : Style de vie
- **Secondaire** : Santé et forme (ou Business pour l’angle prestataire)

---

## Classification d’âge

Répondre au questionnaire Apple (généralement **4+** ou **12+** selon messagerie / paiements — suivre les réponses honnêtes dans Connect).

---

## Notes de version (première soumission)

```
Première version de MadBeauty : découverte de prestataires beauté afro, réservation en ligne, espace pro, messagerie et paiements sécurisés.
```

---

## Informations de contact

- **URL d’assistance** : `https://madbeauty-web.netlify.app/contact.html`
- **E-mail** : `mailto:williamnthiekam392@gmail.com`
- **URL marketing** (optionnel) : `https://madbeauty-web.netlify.app`

---

## Confidentialité de l’app (App Privacy)

Déclarer notamment :

**Important — rejet App Store 5.1.2(i) :** MadBeauty **ne fait pas de suivi publicitaire** (pas de SDK pub, pas de partage avec des courtiers en données). Dans App Store Connect → **Confidentialité de l'app** :

- **Ne pas** cocher « Utilisées pour vous suivre » sur aucune donnée.
- Coordonnées (e-mail, nom) → usages : **Fonctionnalité de l'app**, **Gestion du compte** (pas « Suivi »).
- Position → **Fonctionnalité de l'app** (carte), avec mention du consentement dans l'app.
- Pas besoin d'implémenter App Tracking Transparency (ATT) si aucune donnée n'est déclarée comme tracking.

| Donnée | Usage (App Store Connect) |
|--------|---------------------------|
| Coordonnées (e-mail, nom) | Compte, fonctionnalité de l'app |
| Photos | Profil, galerie prestataire, chat, avis |
| Position précise | Carte et proximité (avec consentement) |
| Identifiants | Connexion, notifications push |
| Achats | Paiements Stripe |

Lier la politique : `https://madbeauty-web.netlify.app/privacy.html`

---

## Notes pour l'équipe d'évaluation (resoumission)

Coller dans **Notes d'évaluation** lors de la prochaine soumission :

```
Confidentialité (5.1.2) : l'app ne pratique pas le suivi publicitaire. Les déclarations App Privacy ont été corrigées (aucune donnée « utilisée pour le suivi »).

Sign in with Apple (directive 4) : après « Continuer avec Apple » sur l'écran Inscription (/register), le prénom, le nom et l'e-mail sont récupérés automatiquement via Authentication Services. Seul le numéro de téléphone est demandé, puis le choix client/prestataire.

Google Sign-In : même comportement — nom et e-mail pré-remplis automatiquement, seul le téléphone est demandé.

Compte test : [si vous en fournissez un — email / mot de passe]
```
