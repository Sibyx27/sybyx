# KIT PÉDAGOGIQUE VALIDÉ — JOURNÉE 2
## Formation « IA & Productivité en entreprise »
### Public : professionnels non-techniciens, PME et grandes entreprises, Bamako

---

## NOTE DE RÉVISIONS PÉDAGOGIQUES APPORTÉES

- **Harmonisation tarifaire** : prix de ChatGPT Plus uniformisé à ~10 000 FCFA/mois sur tout le kit.
- **Cohérence CRTF** : chaque prompt d'exercice et d'exemple comporte les 4 composantes explicitement balisées (C / R / T / F).
- **Ancrage malien renforcé** : exemples ancrés (Hamdallaye ACI, Route de Koulikoro, Médina Coura, Dialakorobougou, Sikasso/Mopti/Kayes ; FCFA ; Orange Money/Wave ; EDM ; BCEAO ; Code du travail malien).
- **Niveau de langage** : « few-shot » toujours suivi de « donner des exemples » ; « hallucination » expliquée comme « erreur présentée avec assurance » ; jargon reformulé.
- **Cohérence inter-journées** : renvois à la J1 vérifiés (CRTF acquise, devoir J1→J2 exploité en ouverture).
- **Neutralité des outils** : présentation factuelle et comparative (ChatGPT, Claude, Gemini, Copilot, Canva IA), sans promotion.

---

# MODULE 3 — MATIN : MAÎTRISER LES TECHNIQUES AVANCÉES DE PROMPT

**Durée totale : 3h30.** **Objectif général :** passer du prompt correct (J1) au prompt professionnel maîtrisé — itérer, donner des exemples, décomposer les tâches complexes, produire des prompts métier de qualité.

---

## SLIDE 3.0 — RETOUR SUR LE DEVOIR J1 → J2  *(20 min)*

**Texte du formateur.** « Bienvenue en Journée 2. Hier, vous avez découvert la méthode CRTF et rédigé votre premier prompt métier. Ce matin, on regarde ce que vous avez produit — c'est là que l'apprentissage devient concret. »

**Mise en commun (5 min seul, 10 min en groupe).** Chaque participant partage : (1) le prompt écrit hier, (2) le résultat obtenu, (3) ce qu'il modifierait aujourd'hui.

**Questions de facilitation :** « Qui a eu une bonne surprise ? » · « Qui a été déçu, et qu'est-ce qui manquait ? » · « Avez-vous retrouvé les 4 composantes CRTF ? »

**Grille de relecture rapide CRTF**

| Composante | Ce que vous avez écrit | Présent ? |
|---|---|---|
| **C** – Contexte | … | Oui / Non |
| **R** – Rôle | … | Oui / Non |
| **T** – Tâche | … | Oui / Non |
| **F** – Format | … | Oui / Non |

**Transition.** « Vous savez construire un bon prompt. Aujourd'hui : quand le premier résultat n'est pas parfait, comment l'améliorer ? C'est l'itération. »

---

## SLIDE 3.1 — L'ITÉRATION : AMÉLIORER SON PROMPT EN 4 NIVEAUX  *(30 min)*

« L'IA n'est pas un oracle. Elle donne une première réponse ; votre travail est de la guider jusqu'au résultat voulu. »

**Niveau 1 — Reformuler la tâche.** Si le résultat est hors sujet, précisez la demande.
- V1 : « Écris une annonce pour mon groupe électrogène. » → texte générique.
- V1-bis : « Écris une annonce de vente pour un groupe électrogène 5 kVA, destinée aux petits commerçants de Bamako qui subissent des coupures EDM fréquentes. Ton commercial, une accroche sur l'autonomie énergétique. »

**Niveau 2 — Contraindre le format.** « Reformate ta réponse en liste à puces de 5 points maximum. Chaque point = une ligne. Pas de paragraphes. »

**Niveau 3 — Changer le ton ou le registre.** « Réécris ce message dans un ton plus chaleureux et direct, comme si vous parliez à un client que vous connaissez depuis longtemps. Gardez le vouvoiement mais allégez le style. »

**Niveau 4 — Demander une version alternative.** « Génère 3 versions différentes : une formelle, une décontractée, une très courte (SMS). Je choisirai la meilleure. »

**Règle pratique.** Avant de tout réécrire, essayez d'ajouter une seule précision — souvent, un mot change tout.

**Transition.** « L'itération améliore le prompt que vous avez. Parfois il faut montrer à l'IA ce que vous attendez, avec des exemples. »

---

## SLIDE 3.2 — DONNER DES EXEMPLES À L'IA  *(technique « few-shot » = donner des exemples)*  *(25 min)*

**Analogie.** « C'est comme former un nouvel employé : lui donner un bon exemple de rapport est plus efficace que de lui décrire comment en écrire un. »

**Structure : montrer avant de demander**

```
Voici un exemple de [ce que vous attendez] :
---EXEMPLE---
[Votre exemple]
---FIN EXEMPLE---

Maintenant, fais la même chose pour [votre cas réel].
```

**Exemple terrain — BTP Bamako (rapport hebdomadaire de chantier)**

> **C** : Je suis responsable de chantier dans une entreprise de BTP à Bamako. Nous construisons un immeuble R+3 sur la Route de Koulikoro (commune IV). Voici un exemple de rapport approuvé par ma direction :
> ---EXEMPLE---
> **Semaine du 3 au 7 mars 2025 — Chantier Hamdallaye ACI.** Avancement : fondations 100 %, coffrage RDC 70 %. Effectif : 12 maçons, 4 ferronniers, 1 chef d'équipe. Incidents : livraison ciment retardée de 2 jours (fournisseur Bamako). Prévision : coulage dalle RDC jeudi/vendredi.
> ---FIN EXEMPLE---
> **R** : Tu es mon assistant administratif de chantier, familier du vocabulaire BTP et des contraintes terrain en Afrique de l'Ouest.
> **T** : Génère le rapport pour la semaine du 14 au 18 avril 2025. Données : coffrage RDC 100 %, dalle coulée vendredi 18, effectif identique, aucun incident majeur, prévision : démarrage murs RDC.
> **F** : Même format que l'exemple. 5 à 8 lignes max. Vocabulaire professionnel BTP.

**Pourquoi ça marche ?** En donnant un exemple, vous calibrez l'IA sur votre style, votre vocabulaire, votre niveau de détail.

**Transition.** « Pour les projets lourds, l'IA a besoin que vous découpiez le travail en étapes : c'est la décomposition. »

---

## SLIDE 3.3 — DÉCOMPOSER LES TÂCHES COMPLEXES  *(25 min)*

**Principe.** Une tâche complexe = plusieurs prompts séquentiels. Le résultat de l'étape N devient le matériau de l'étape N+1.

**Exemple terrain — Lancement d'un riz importé premium à Bamako (25 kg)**

**Étape 1 — Analyse du marché**
> **C** : Je dirige une société d'import-export à Bamako ; nous lançons une marque de riz premium au Mali. **R** : Tu es expert en analyse de marché pour les biens de grande consommation en Afrique de l'Ouest. **T** : Analyse les 3 principaux défis (comportements d'achat des ménages, concurrence locale, sensibilité au prix en FCFA). **F** : 3 parties titrées, 5 lignes max chacune.

**Étape 2 — Positionnement et prix** *(en réutilisant l'étape 1)*
> **C** : Suite à l'analyse précédente ; défis identifiés : [coller le résumé étape 1]. **R** : Tu es consultant en stratégie commerciale pour PME africaines. **T** : Propose un positionnement prix pour un sac 25 kg, avec 3 scénarios tarifaires en FCFA et les arguments de vente pour les revendeurs de Bamako. **F** : Tableau 3 colonnes (Scénario / Prix FCFA / Arguments revendeur), 3 lignes.

**Étape 3 — Plan de communication**
> **C** : Lancement au prix de [étape 2], cible ménages classe moyenne à Bamako, Sikasso, Mopti, Kayes. **R** : Tu es responsable marketing digital spécialisé marché malien. **T** : Plan de communication sur 30 jours (Facebook/WhatsApp, points de vente, bouche-à-oreille), budget 500 000 FCFA. **F** : Plan par semaine (S1-S4), pour chaque semaine : actions, canal, budget FCFA.

**Étape 4 — Objections et réponses**
> **C** : Contexte de clients habitués au riz moins cher. **R** : Tu es formateur en techniques de vente pour le marché malien. **T** : Liste les 5 objections les plus fréquentes et une réponse commerciale pour chacune. **F** : Tableau 2 colonnes (Objection / Réponse), 5 lignes.

**Règle pratique.** Si votre tâche demande plus de 3 paragraphes de description, c'est qu'elle doit être découpée.

---

## SLIDE 3.4 — ATELIERS PROFESSIONNELS PAR MÉTIER  *(50 min + 15 min restitution)*

4 groupes en parallèle : **A** Commerce/Vente, **B** RH/Admin, **C** Comptabilité/Gestion, **D** Communication/Marketing.

### BLOC A — COMMERCE / VENTE

**A1 — Relance WhatsApp**
> **C** : Commercial dans une entreprise de distribution de matériel informatique à Bamako (commune III) ; devis de 2 450 000 FCFA pour 5 ordinateurs portables envoyé à M. Diallo (PME de Hamdallaye ACI) il y a 5 jours, sans réponse. **R** : Expert en relance commerciale, marché des affaires de Bamako. **T** : Rédige une relance WhatsApp chaleureuse mais professionnelle (rappeler le devis, exprimer notre disponibilité, proposer un rendez-vous cette semaine). **F** : 4 à 6 lignes max, ton direct et respectueux.

**A2 — Objection prix**
> **C** : Commercial en fournitures de bureau à Bamako ; le client dit avoir trouvé moins cher ailleurs. **R** : Formateur en négociation commerciale en Afrique de l'Ouest. **T** : Propose 3 réponses (qualité ; relation de confiance ; arrangement de paiement via Orange Money). **F** : 3 paragraphes courts, 2-3 phrases chacun.

### BLOC B — RH / ADMINISTRATION

**B1 — Offre d'emploi**
> **C** : DRH d'une société de gardiennage et sécurité privée à Bamako (80 agents) ; recrutement de 15 agents pour la zone industrielle de Dialakorobougou. **R** : Expert RH (secteur sécurité, Afrique de l'Ouest). **T** : Rédige une offre d'emploi d'Agent de Sécurité (missions, profil, avantages — salaire FCFA conforme au SMIG malien, tenue, formation ; modalités de candidature). **F** : Offre structurée, une page A4, français accessible niveau BEPC/BAC.

**B2 — Note congés (Code du travail malien)**
> **C** : Responsable administratif d'une entreprise de 35 salariés à Bamako ; questions des employés sur les congés annuels. **R** : Juriste en droit social et droit du travail malien. **T** : Rédige une note interne (durée légale, acquisition, prise, indemnité de congés payés ; mention de l'ancienneté). **F** : Note de service, 4-5 paragraphes avec sous-titres, langage accessible.
>
> ⚠️ *Point de vigilance à lire : cette note est un point de départ ; faites-la vérifier par un juriste ou l'Inspection du travail. **L'IA propose, vous validez.***

### BLOC C — COMPTABILITÉ / GESTION

**C1 — Analyse de ventes**
> **C** : Comptable d'une PME de négoce à Bamako ; ventes T1 2025 : janvier 18 500 000, février 14 200 000, mars 22 800 000 FCFA ; objectif trimestriel 55 000 000 ; coût des marchandises vendues 38 200 000 FCFA. **R** : Analyste financier (PME commerciales d'Afrique de l'Ouest). **T** : (1) performance vs objectif, (2) marge brute en FCFA et %, (3) tendance mensuelle, (4) recommandation pour le T2. **F** : Rapport en 4 parties numérotées, chiffres en FCFA, accessible à une direction non-financière.

**C2 — Relance impayé (2e rappel)**
> **C** : Gérant d'une entreprise de fournitures industrielles à Bamako ; la SARL Coulibaly & Frères doit 1 750 000 FCFA depuis 90 jours ; 1er rappel téléphonique ignoré. **R** : Expert en recouvrement de créances, pratiques commerciales et juridiques au Mali. **T** : Lettre de relance formelle (rappel montant/date, mention du 1er rappel resté sans suite, délai de 15 jours ouvrables, recours possibles). **F** : Lettre formelle (en-tête, date, objet, 3 paragraphes, politesse), ton ferme mais professionnel.

### BLOC D — COMMUNICATION / MARKETING

**D1 — Série de posts Facebook**
> **C** : Société de nettoyage industriel et facilities management à Bamako (bureaux, hôtels, chantiers) ; promotion -15 % sur les premiers contrats signés en juin. **R** : Community manager (PME de services, Afrique francophone, audience Facebook malienne). **T** : 3 posts (annonce ; témoignage client fictif ; rappel dernière chance) avec appels à l'action (WhatsApp/appel). **F** : 3 posts séparés, 5-8 lignes chacun, 2-3 emojis, ton dynamique adapté au public bamakois.

**D2 — Plan vente flash Tabaski**
> **C** : Responsable marketing d'une boutique de prêt-à-porter à Bamako (Médina Coura) ; Tabaski dans 3 semaines ; budget 150 000 FCFA. **R** : Consultant marketing événementiel (commerces de détail, Afrique de l'Ouest, fêtes religieuses). **T** : Plan de vente flash sur 3 semaines (communication Facebook/WhatsApp/affichage ; offres ; répartition du budget). **F** : Plan par semaine (préparation / lancement / intensification), 3 actions + budget FCFA par semaine, total = 150 000 FCFA.

**Restitution (15 min).** Chaque groupe présente son meilleur prompt ; le formateur vérifie les 4 composantes CRTF et suggère une itération.

---

## SLIDE 3.5 — SYNTHÈSE MATINÉE + TRANSITION  *(10 min)*

| Technique | Ce que ça fait | Quand l'utiliser |
|---|---|---|
| **Itération** (4 niveaux) | Affiner un prompt imparfait | Toujours — réflexe de base |
| **Donner des exemples** (few-shot) | Calibrer l'IA sur votre style/format | Quand vous avez un modèle existant |
| **Décomposition** | Traiter les projets complexes par étapes | Dès que la tâche dépasse 3 paragraphes |
| **CRTF avancé** | Prompts professionnels complets | Systématiquement pour toute tâche importante |

**Sur les limites.** L'IA peut commettre une **erreur présentée avec assurance** (« hallucination ») : chiffre inexact, loi mal citée. Pour tout ce qui engage l'entreprise, **vérifiez toujours**.

---

## EXERCICE DE FIN DE MATINÉE — « MON PROMPT MÉTIER EN 3 VERSIONS »  *(20 min)*

Choisissez une tâche réelle et rédigez-la en 3 versions : **V1** prompt brut (avant la formation) ; **V2** prompt CRTF (après J1) ; **V3** prompt avancé (≥ 2 techniques du matin).

**Grille d'auto-évaluation**

| Critère | V1 | V2 | V3 |
|---|---|---|---|
| Contexte présent et précis | ☐ | ☐ | ☐ |
| Rôle assigné à l'IA | ☐ | ☐ | ☐ |
| Tâche claire et unique | ☐ | ☐ | ☐ |
| Format spécifié | ☐ | ☐ | ☐ |
| Technique avancée utilisée | — | — | ☐ |
| Ancrage métier/local | ☐ | ☐ | ☐ |

**Objectif :** chaque participant repart avec au moins un prompt métier validé, réutilisable dès le lendemain.

---

# MODULE 4 — APRÈS-MIDI : DÉPLOYER L'IA DANS SON ENTREPRISE

**Durée totale : 3h30.** **Objectif général :** choisir les bons outils, protéger les données, embarquer son équipe, mesurer les gains, et construire son plan d'adoption sur 30 jours.

---

## SLIDE 4.1 — CHOISIR SES OUTILS : 5 CRITÈRES TERRAIN AU MALI  *(30 min)*

**Critère 1 — La langue.** ChatGPT : très bon en français ; Claude : excellent en français ; Gemini : bon, intégré à Google Workspace ; Copilot : bon, intégré à Word/Excel/Outlook. (Langues locales africaines : globalement limitées.)

**Critère 2 — La connectivité.** Préparez les prompts importants hors ligne ; travaillez aux heures de moindre congestion ; pendant les coupures EDM, priorisez les tâches IA urgentes (groupe électrogène/batterie) ; copiez les réponses importantes dans un document local avant de fermer la session.

**Critère 3 — Le budget (équivalents approximatifs en FCFA)**

| Outil | Version gratuite | Version payante |
|---|---|---|
| **ChatGPT** | Oui (limité) | ~10 000 FCFA/mois (Plus) |
| **Claude** | Oui (limité) | ~15 000 FCFA/mois environ |
| **Gemini** | Oui (intégré Google) | Inclus dans Google Workspace (~5 000-10 000 FCFA/mois) |
| **Copilot Microsoft** | Basique gratuit | Inclus dans Microsoft 365 (~6 000-12 000 FCFA/mois) |
| **Canva IA** | Oui (limité) | ~5 000-8 000 FCFA/mois |

> Prix indicatifs au taux courant, à vérifier sur les sites des outils. Paiement généralement par carte bancaire internationale (Visa/Mastercard) — Orange Money et Wave ne sont pas encore acceptés directement.

**Critère 4 — L'intégration.** Google Workspace → Gemini ; Microsoft Office → Copilot ; usage général → ChatGPT/Claude ; communication visuelle → Canva IA.

**Critère 5 — La tâche**

| Tâche | Outil(s) recommandé(s) |
|---|---|
| Rédaction (courriers, rapports, emails) | ChatGPT, Claude, Copilot (Word) |
| Analyse de données (Excel) | Copilot (Excel), ChatGPT |
| Présentations visuelles | Canva IA, Copilot (PowerPoint) |
| Résumé de documents longs | Claude, ChatGPT |
| Transcription de réunions | Otter.ai, Whisper, Gemini |
| Traduction FR ↔ EN | DeepL, ChatGPT, Gemini |

**Recommandation pour débuter :** commencez par **ChatGPT gratuit** ; si usage quotidien et gains réels, envisagez Plus (~10 000 FCFA/mois).

---

## SLIDE 4.2 — CONFIDENTIALITÉ ET VÉRIFICATION  *(25 min)*

**🔴 ROUGE — Ne jamais envoyer à une IA :** identifiants bancaires, codes/PIN, mots de passe ; données personnelles identifiables de clients (nom + téléphone + adresse) ; secrets commerciaux ; stratégies non publiques ; salaires individuels ; données médicales/judiciaires ; tout document « confidentiel ».

**🟠 ORANGE — Anonymiser avant d'envoyer :** données financières (remplacer par des chiffres fictifs du même ordre) ; courriers avec noms (« M. X, directeur d'une PME de négoce ») ; contrats (anonymiser parties et montants sensibles).

**🟢 VERT — Libre d'utilisation :** textes sans données personnelles ; reformulation/amélioration de style ; contenu générique ; données publiques ; questions d'apprentissage.

**La règle des 3 vérifications** (pour toute info factuelle importante) : (1) puis-je confirmer dans une source officielle malienne (administration, BCEAO, CCI Mali) ? (2) est-ce cohérent avec mon secteur ? (3) quel risque si j'agis et que c'est faux ?

> Finances : **BCEAO** (bceao.int). Juridique : Inspection du travail, Tribunal de commerce, juriste qualifié. L'IA peut se tromper de façon convaincante (« erreur présentée avec assurance »).

**Principe fondamental : « L'IA PROPOSE. VOUS DISPOSEZ. »**

---

## SLIDE 4.3 — EMBARQUER SON ÉQUIPE  *(25 min)*

**4 résistances fréquentes et réponses :**
1. *« J'ai peur de perdre mon travail »* → l'IA remplace les tâches répétitives, pas le collaborateur compétent (analogie : la calculatrice n'a pas supprimé les comptables).
2. *« C'est trop compliqué pour moi »* → si vous savez écrire un SMS, vous savez utiliser une IA de base ; on commence par une tâche simple, ensemble.
3. *« On ne peut pas faire confiance à une machine »* → prudence justifiée ; d'où les règles de vérification ; l'IA est un assistant, vous restez responsable.
4. *« On s'en est passé jusqu'ici »* → l'IA aide à faire mieux avec moins d'efforts ; pas une obligation, un outil de plus ; on commence par ce qui fait gagner du temps.

**Stratégie d'adoption en 3 phases :** **Montrer** (S1-2 : vous l'utilisez, vous montrez les résultats) → **Former un pilote** (S3-4 : 1-2 volontaires motivés, valoriser leurs résultats) → **Généraliser** (mois 2-3 : session d'équipe, tâches « IA-assistées » par défaut, bibliothèque de prompts partagée, mesure des gains).

**Vigilance.** N'imposez jamais l'IA comme contrainte hiérarchique — proposez-la comme un avantage.

---

## SLIDE 4.4 — MESURER LE TEMPS GAGNÉ  *(20 min)*

**4 indicateurs :** temps de rédaction (objectif : -50 à -70 % sur les tâches répétitives) ; nombre de tâches « évitées » ; qualité perçue (clients/collègues) ; délai de traitement.

**Le « Journal IA » (30 jours)**

| Date | Tâche avec l'IA | Temps SANS IA | Temps AVEC IA | Gain | Qualité (1-5) |
|---|---|---|---|---|---|
| 16/06 | Rédaction offre commerciale | 2h | 25 min | 1h35 | 4/5 |
| 17/06 | Note interne congés | 45 min | 10 min | 35 min | 5/5 |
| … | … | … | … | … | … |

**ROI simple.** ChatGPT Plus ~10 000 FCFA/mois ; gain ~1h/jour (~20h/mois) ; heure à 3 000 FCFA → 60 000 FCFA/mois de valeur → **6× le coût de l'abonnement**.

---

## SLIDE 4.5 — ÉTHIQUE ET RESPONSABILITÉ  *(20 min)*

**5 questions à se poser :** (1) Vais-je présenter comme entièrement mien un contenu que l'IA a produit ? (relisez, corrigez, appropriez-vous-le) — (2) Est-ce que je transmets des données de tiers sans accord ? — (3) Le résultat peut-il être discriminatoire/biaisé ? — (4) Est-ce que je vérifie les faits avant d'agir ? — (5) Mon usage respecte-t-il les règles de mon secteur/entreprise ?

**Cadre réglementaire au Mali (2025-2026).** Pas de loi spécifique IA, mais s'appliquent : la **loi sur la cybercriminalité** (usage frauduleux/usurpation/fausses infos punissable) ; la **protection des données personnelles** ; pour le secteur financier, les directives de la **BCEAO** (fintech, paiement mobile) ; la responsabilité du contenu publié (diffamation, publicité mensongère, vie privée).

**Principe directeur :** utilisez l'IA comme tout outil professionnel — avec compétence, dans le respect des règles de votre métier, en assumant la responsabilité de ce que vous produisez.

---

## EXERCICE FINAL — « MON PLAN D'ADOPTION IA — 30 JOURS »  *(30 min : individuel + binôme)*

**Nom :** ______________________  **Entreprise :** ______________________  **Date :** __________

### BLOC 1 — Mon profil IA actuel

| Question | Ma réponse |
|---|---|
| Mon niveau aujourd'hui | Débutant / Quelques essais / Utilisateur occasionnel |
| L'outil IA déjà utilisé | _____________________ |
| Ce qui m'a retenu jusqu'ici | _____________________ |

### BLOC 2 — Mes 3 tâches prioritaires pour l'IA

| # | Tâche | Fréquence/sem | Temps actuel | Gain potentiel |
|---|---|---|---|---|
| 1 | _______________ | ___ /sem | ___ min | ___ min |
| 2 | _______________ | ___ /sem | ___ min | ___ min |
| 3 | _______________ | ___ /sem | ___ min | ___ min |
| **TOTAL** | | | | **___ min/sem** |

### BLOC 3 — Mon outil et mon budget

| Question | Ma décision |
|---|---|
| Outil principal | _____________________ |
| Gratuit ou payant ? | Gratuit pour commencer / Payant (~10 000 FCFA/mois, ChatGPT Plus) |
| Date de démarrage | _____________ |
| Moyen de paiement si abonnement | Carte bancaire internationale : Oui / Pas encore |

### BLOC 4 — Mon plan semaine par semaine

**Semaine 1 — Installer et tester**

| Action | Fait ? |
|---|---|
| Créer mon compte sur l'outil choisi | ☐ |
| Premier prompt CRTF sur une tâche réelle (tâche : __________) | ☐ |
| Noter le résultat dans mon Journal IA | ☐ |

**Semaine 2 — Maîtriser les bases**

| Action | Fait ? |
|---|---|
| Utiliser l'IA ≥ 3 fois | ☐ |
| Pratiquer l'itération sur un prompt imparfait | ☐ |
| Utiliser « donner des exemples » sur un document récurrent (tâche : __________) | ☐ |

**Semaine 3 — Monter en puissance**

| Action | Fait ? |
|---|---|
| Utiliser l'IA chaque jour (même 10 min) | ☐ |
| Décomposer une tâche complexe en plusieurs prompts (tâche : __________) | ☐ |
| Partager un résultat positif avec un collègue | ☐ |

**Semaine 4 — Consolider et partager**

| Action | Fait ? |
|---|---|
| Constituer une bibliothèque de 5 prompts métier réutilisables | ☐ |
| Former/montrer à 1 collègue | ☐ |
| Bilan du Journal IA (temps total gagné sur le mois) | ☐ |
| Décider : abonnement payant ou gratuit | ☐ |

### BLOC 5 — Mon engagement et ma mesure de succès

Dans 30 jours, j'aurai réussi si : ______________________________________________

Mon partenaire de suivi : Nom ____________________ Contact ____________________

Signature : ____________________  Date : __________

**Partage en binôme (10 min).** Le voisin pose : « Qu'est-ce qui pourrait t'empêcher de faire ça ? » et aide à anticiper un obstacle.

---

## SLIDE DE CLÔTURE — JOURNÉE 2  *(15 min)*

**Ce que vous savez faire maintenant :** construire un prompt CRTF professionnel · itérer en 4 niveaux · donner des exemples · décomposer les projets complexes · choisir l'outil adapté · protéger les données · embarquer votre équipe · mesurer vos gains et votre ROI · utiliser l'IA de façon éthique.

**Message final.** « L'IA ne remplacera pas ceux qui savent l'utiliser — elle amplifiera leur capacité à produire, décider, créer. Ce qui fait la différence, c'est la pratique régulière, ancrée dans votre réalité à Bamako. Votre plan des 30 jours est votre premier pas. »

**Ressources pour continuer**

| Ressource | Accès |
|---|---|
| ChatGPT | chat.openai.com |
| Claude | claude.ai |
| Gemini | gemini.google.com |
| Canva IA | canva.com |
| Tutoriels YouTube (FR) | « prompts IA débutants français » |
| BCEAO (vérifs financières) | bceao.int |

*Distribuer la fiche d'évaluation de la formation (5 min).*

---

# ANNEXE — 8 PROMPTS MÉTIER PRÊTS À L'EMPLOI

Adaptez les éléments entre crochets `[ ]` à votre contexte réel.

| # | Métier | Tâche | Prompt CRTF |
|---|---|---|---|
| 1 | Commerce/Vente | Relance client devis | **C** : commercial chez [entreprise] à Bamako ; devis de [montant] FCFA à [M./Mme X, fonction] il y a [X] jours, sans réponse. **R** : expert en relance commerciale (Bamako). **T** : relance WhatsApp chaleureuse et pro (rappel du devis, disponibilité, proposer un RDV). **F** : 5 lignes max, ton direct et respectueux, vouvoiement. |
| 2 | RH/Admin | Offre d'emploi | **C** : DRH de [entreprise] à [quartier de Bamako] ; recrutement de [X] [poste] pour [contexte]. **R** : expert RH au Mali. **T** : offre complète (missions, profil, avantages en FCFA, modalités de candidature). **F** : structurée, 1 page A4, français accessible BEPC-Licence. |
| 3 | Compta/Gestion | Analyse de ventes | **C** : [comptable/DAF/gérant] d'une [entreprise] à Bamako ; chiffres [période] : [données FCFA]. **R** : analyste financier (PME africaines). **T** : (1) performance vs objectif, (2) marge brute FCFA et %, (3) tendance, (4) recommandation. **F** : 4 parties numérotées, FCFA, accessible à une direction non-financière. |
| 4 | Communication | Posts réseaux sociaux | **C** : [entreprise], [secteur] à Bamako ; lancement de [produit/promo] ; cible [public malien]. **R** : community manager (Afrique francophone). **T** : 3 posts Facebook (annonce / témoignage / urgence) avec appels à l'action. **F** : 3 posts, 6-8 lignes, 2-3 emojis, ton dynamique bamakois. |
| 5 | Direction | Compte rendu de réunion | **C** : [directeur/responsable] ; notes brutes du [date] sur [sujet] : [coller]. **R** : assistant de direction. **T** : compte rendu (participants, points, décisions, actions avec responsable et délai). **F** : formel, 4 sections, actions en puces, 1 page A4. |
| 6 | Logistique/Transport | Suivi livraison | **C** : responsable logistique à Bamako ; livraison de [produit] pour [client] retardée de [X] jours pour [raison]. **R** : expert en communication client logistique. **T** : message d'excuse + info (nouvelle date [date]) + geste commercial si approprié. **F** : 6-8 lignes, ton sincère, SMS/WhatsApp/email. |
| 7 | Hôtellerie/Restauration | Réponse à un avis négatif | **C** : [établissement] à [lieu] ; avis négatif : « [coller] ». **R** : expert e-réputation hospitalité en Afrique. **T** : réponse publique (reconnaître, excuses sincères si justifié, mesures, inviter à revenir). **F** : 5-7 lignes, ton humble et constructif, sans agressivité. |
| 8 | Multi-secteurs | Synthèse de document long | **C** : je dois comprendre [type] de [X] pages sur [sujet] : [coller]. **R** : assistant de synthèse. **T** : (1) objectif, (2) 5 points clés, (3) chiffres importants, (4) actions requises. **F** : 4 sections titrées, 1 page max, langage clair. |

---

*Fin du Kit Pédagogique Validé — Journée 2. Méthode CRTF — version révisée et validée.*
