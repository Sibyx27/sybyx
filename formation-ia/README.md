# Formation « IA & Productivité en entreprise » — Kit complet

Formation de 2 jours destinée aux équipes de PME et grandes entreprises maliennes (Bamako).

- **Public :** professionnels non-techniciens
- **Langue :** français
- **Méthode pédagogique :** CRTF — **C**ontexte, **R**ôle, **T**âche, **F**ormat
- **Contraintes terrain :** coupures EDM, connexion instable, travail sur mobile, paiements Orange Money / Wave, tarifs en FCFA

## Contenu du kit

Chaque fichier `.md` est accompagné de sa version `.pdf` (A4, prête à imprimer/diffuser), générée par [`build_pdf.py`](./build_pdf.py).

### Jour 1

| Fichier | Livrable |
|---|---|
| [`J1-pedagogie.md`](./J1-pedagogie.md) | Contenu pédagogique Jour 1 — Module 1 (intro IA + cas Afrique) + Module 2 (prompting CRTF), validé et adapté au contexte malien |
| [`logistique-1-checklist-materiel.md`](./logistique-1-checklist-materiel.md) | Checklist matériel formateur (6 catégories, secours EDM/réseau) |
| [`logistique-2-plan-de-salle.md`](./logistique-2-plan-de-salle.md) | Plan de salle pour 15 participants (disposition en U, recharge mobile) |
| [`logistique-3-protocole-coupure.md`](./logistique-3-protocole-coupure.md) | Protocole coupure EDM / réseau (3 scénarios, seuils de décision) |
| [`logistique-4-fiche-recap-J1.md`](./logistique-4-fiche-recap-J1.md) | Fiche récap J1 à imprimer et distribuer aux participants |

### Jour 2

| Fichier | Livrable |
|---|---|
| [`J2-pedagogie.md`](./J2-pedagogie.md) | Contenu pédagogique Jour 2 — Module 3 (prompting avancé & cas par métier) + Module 4 (déploiement en entreprise + plan d'adoption 30 jours) + annexe 8 prompts métier |
| [`logistique-J2-kit-complet.md`](./logistique-J2-kit-complet.md) | Logistique J2 : checklist complémentaire, déroulé horaire (intensité réseau/batterie), organisation des 4 ateliers métier, fiche récap/clôture J2 |
| [`fiche-recap-J2.md`](./fiche-recap-J2.md) | Fiche récap/clôture J2 en document participant autonome (extraite du kit logistique) |

### Fiches participant — format mobile

Les fiches distribuées en fin de journée existent aussi en **version mobile** (page étroite type écran de téléphone, texte agrandi), à diffuser via WhatsApp aux participants :

- `logistique-4-fiche-recap-J1-mobile.pdf`
- `fiche-recap-J2-mobile.pdf`

Pour régénérer une version mobile : `python3 build_pdf.py --mobile <fichier>.md`

### Documents de clôture (administratif)

| Fichier | Livrable |
|---|---|
| [`attestation-participation.md`](./attestation-participation.md) | Modèle d'attestation de participation (1 par participant, à personnaliser et signer) |
| [`evaluation-a-chaud.md`](./evaluation-a-chaud.md) | Fiche d'évaluation à chaud (10 affirmations notées 1-5 + questions ouvertes), à remplir anonymement en fin de formation |
| [`actualite-ia-veille.md`](./actualite-ia-veille.md) | Veille « actualité IA » pour le formateur — instantané daté (international + Afrique/Mali) **à régénérer avant chaque session** ; inclut un prompt CRTF de mise à jour |

### Module thématique ciblé RH

| Fichier | Livrable |
|---|---|
| [`RH-ia-formation.md`](./RH-ia-formation.md) | Formation « L'IA en Ressources Humaines : intérêt, risques et opportunités » — 7 cas d'usage RH (prompts CRTF), 6 risques, 5 opportunités, bonnes pratiques, 2 exercices terrain et charte RH |
| [`charte-ia-rh.md`](./charte-ia-rh.md) | Charte d'usage de l'IA en RH (12 règles) en document autonome à personnaliser/signer — version standard et **mobile** (`charte-ia-rh-mobile.pdf`) |

## Méthode de production

Kit produit par une équipe de 3 agents en pipeline :

1. **Contenu** — slides J1 matin (introduction IA, cas Afrique) et après-midi (prompting CRTF, exercices).
2. **Pédagogue** — vérification de la cohérence CRTF de chaque exercice, adaptation des exemples au contexte malien, ajustement du niveau de langage pour des non-techniciens.
3. **Logistique** — checklist matériel, plan de salle, protocole coupure EDM/réseau, fiche récap.
