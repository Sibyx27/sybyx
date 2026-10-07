# FORMATION IA & PRODUCTIVITÉ — FICHE RÉCAP JOUR 2
### Ce que vous avez appris ces deux jours — gardez cette fiche, elle vous sera utile chaque semaine

*Fiche participant — à remettre en fin de formation avec l'attestation.*

---

## PARTIE 1 — LES 3 LEVIERS DU PROMPTING AVANCÉ (Module 3)

La méthode CRTF vue au Jour 1 est votre base. Ces 3 leviers vous permettent d'aller plus loin quand la réponse n'est pas encore satisfaisante.

### LEVIER 1 — L'ITÉRATION : améliorer la réponse en continuant la conversation

Ne jetez pas une conversation à la première réponse décevante. L'IA comprend le contexte des échanges précédents. Exemples de relances :

> « C'est bien mais trop long — résume en 5 lignes maximum. »
> « Reformule de manière plus formelle, pour une lettre officielle. »
> « Donne-moi 3 alternatives à la version que tu viens de proposer. »
> « En tenant compte de ce que tu as écrit, ajoute une section sur les délais de paiement. »

**Règle d'or :** 3 itérations suffisent dans 90 % des cas. Si vous n'êtes toujours pas satisfait à la 3ᵉ relance, recommencez avec un prompt CRTF mieux construit.

### LEVIER 2 — DONNER DES EXEMPLES (few-shot prompting)

L'IA produit de bien meilleurs résultats quand vous lui montrez le style, le ton ou le format voulu, au lieu de seulement le décrire.

**Sans exemple (générique) :** « Rédige un message WhatsApp pour relancer un client. »

**Avec exemple (adapté à votre réalité) :** « Rédige un message WhatsApp pour relancer un client. Voici mon style habituel : *"Bonjour M. Coulibaly, j'espère que vous allez bien. Je voulais prendre de vos nouvelles et vous informer de nos promotions de la semaine sur les ciments..."* Garde ce ton chaleureux et professionnel. »

Autres façons : coller un ancien email/rapport (« écris dans le même style ») ou donner 2-3 exemples que vous approuvez (« génère-en 5 autres dans le même esprit »).

### LEVIER 3 — DÉCOMPOSER UNE TÂCHE COMPLEXE

Découpez les grosses tâches en plusieurs échanges. Exemple — rapport de bilan mensuel :

> Étape 1 → « Liste les 5 sections d'un rapport de bilan mensuel pour une PME commerciale. »
> Étape 2 → « Pour la section "Analyse des ventes", donne les 3 questions clés. »
> Étape 3 → « Voici mes chiffres de ventes [données]. Rédige la section en répondant aux 3 questions. »

**Pourquoi ça marche :** l'IA reste concentrée sur une sous-tâche, les réponses sont plus précises, et vous gardez le contrôle.

---

## PARTIE 2 — QUEL OUTIL POUR QUEL USAGE ?

| Besoin | Outil recommandé | Coût |
|--------|-----------------|------|
| Rédaction (emails, rapports, courriers) | ChatGPT ou Gemini | Gratuit |
| Q/R complexes, recherche documentaire | ChatGPT, Perplexity | Gratuit / ~10 000 FCFA/mois |
| Recherche web avec sources | Perplexity AI | Gratuit |
| Résumés de PDF | ChatGPT Plus, Gemini Advanced | ~10 000 FCFA/mois |
| Images (affiches, visuels) | DALL·E, Canva IA | ~10 000 FCFA/mois |
| Données chiffrées (CSV) | ChatGPT, Gemini | Gratuit |
| Traduction (bamanankan, etc.) | ChatGPT, Gemini | Gratuit |
| Préparer réunion/formation | ChatGPT, Claude | Gratuit |

> **Conseil terrain Bamako :** commencez avec ChatGPT gratuit + Gemini. Au-delà de 30 min/jour, la version Plus (~10 000 FCFA/mois) se rentabilise en quelques heures économisées.

---

## PARTIE 3 — RÈGLES DE CONFIDENTIALITÉ (FEU ROUGE / ORANGE / VERT)

L'IA est hébergée hors du Mali. Ce que vous tapez peut servir à améliorer le modèle. Soyez prudents.

**🔴 FEU ROUGE — NE JAMAIS METTRE DANS L'IA**
- Mots de passe, codes PIN, numéros de compte bancaire
- Numéros de carte ou données Orange Money / Wave
- Informations médicales nominatives de clients
- Données personnelles de salariés (CNI, salaire)
- Clauses contractuelles confidentielles avec noms
- Stratégies commerciales non publiques avec noms réels

**🟡 FEU ORANGE — UTILISER AVEC PRÉCAUTION**
- Données financières de l'entreprise (sans nom/compte)
- Noms de clients importants (remplacez par « Client X »)
- Contenus liés à des appels d'offres en cours
- Informations RH sensibles (anonymisez avant de coller)

**🟢 FEU VERT — UTILISATION SANS RESTRICTION**
- Rédaction de textes génériques (sans données sensibles)
- Conseils, idées, brainstorming
- Traductions, reformulations, résumés de textes publics
- Préparation de présentations, plans d'action
- Apprentissage, formation, exercices

**Règle pratique :** avant de coller un texte, demandez-vous : « Serais-je à l'aise si ce texte était lu par quelqu'un d'autre ? » Si non, anonymisez ou n'utilisez pas l'IA.

**Référence :** recommandations de la BCEAO sur les données numériques (www.bceao.int).

---

## PARTIE 4 — VOTRE PLAN D'ADOPTION IA — 30 JOURS

| Bloc | Contenu | Votre engagement |
|------|---------|-----------------|
| **Semaine 1** | 1 seule tâche répétitive confiée à l'IA | La faire TOUS les jours avec l'IA |
| **Semaine 2** | Ajouter une 2ᵉ tâche + mesurer le gain | Chronométrer avant/après |
| **Semaine 3** | Former 1 collègue à cette tâche | 30 min de partage informel |
| **Semaine 4** | Présenter les résultats à la hiérarchie | 5 slides max ou 1 page |

**Suivi entre pairs (groupe WhatsApp) :** chaque semaine, partager 1 prompt qui a bien marché ; à J+15, un message « J'ai utilisé l'IA pour [tâche]. Résultat : [gain] » ; à J+30, mini-bilan collectif de 30 min.

---

## PARTIE 5 — VOS 3 PREMIÈRES ACTIONS DÈS DEMAIN MATIN

> **Lisez ceci ce soir ou demain matin avant d'aller au bureau.**

**Action 1 (15 min) — Testez votre meilleur prompt.** Ouvrez ChatGPT ou Gemini, envoyez le prompt V3 rédigé en atelier, notez le résultat, faites une itération si besoin.

**Action 2 (5 min) — Choisissez une tâche de demain à confier à l'IA.** Regardez votre agenda : une tâche où vous devez écrire, résumer ou préparer. Décidez de la faire avec l'IA avant de la faire seul.

**Action 3 (2 min) — Restez actif dans le groupe WhatsApp.** Postez ce soir : « Je vais utiliser l'IA demain pour [tâche]. Je partage le résultat dans 24 h. » Cet engagement public augmente fortement les chances de passer à l'acte.

---

## RESSOURCES POUR CONTINUER

| Ressource | Accès | Utilité |
|-----------|-------|---------|
| **ChatGPT** | chatgpt.com / appli | Outil principal recommandé |
| **Gemini** | gemini.google.com | Alternative gratuite, bonne en français |
| **Perplexity AI** | perplexity.ai | Recherche avec sources citées |
| **BCEAO** | www.bceao.int | Vérifications réglementaires |
| **YouTube (FR)** | « ChatGPT débutant », « Gemini tutoriel » | Vidéos de 10-15 min |
| **ChatGPT Plus** | ~10 000 FCFA/mois | Via revendeurs Orange Money ou carte Visa |

**Formateur — WhatsApp :** `____________________`   ·   **Groupe de suivi :** `____________________`

---

*Formation « IA & Productivité en entreprise » — Bamako | Document réservé aux participants.*
*Jour 2 — Module 3 (prompting avancé) + Module 4 (adoption & outils).*
