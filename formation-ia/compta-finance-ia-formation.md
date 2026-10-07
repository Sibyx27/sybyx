# L'IA EN COMPTABILITÉ & FINANCE : INTÉRÊT, RISQUES ET OPPORTUNITÉS
## Module thématique ciblé Comptabilité & Finance — Formation demi-journée à journée
### Programme « IA & Productivité en entreprise » — Public : professionnels comptables et financiers non-techniciens — Bamako, Mali

---

## NOTE DE RÉVISIONS PÉDAGOGIQUES APPORTÉES

- **CRTF renforcé** : chaque prompt-exemple est rédigé avec les 4 composantes explicitement étiquetées (C / R / T / F) et vérifiées ; les Rôles et Formats implicites ont été développés.
- **Ancrage malien renforcé** : exemples sectoriels variés (commerce général, BTP, hôtellerie, ONG, transit, agroalimentaire, services) ; références DGI, SYSCOHADA/OHADA, BCEAO, NIF, Orange Money/Wave, EDM, FCFA.
- **Langage non-technicien** : « hallucination » → « erreur présentée avec assurance » partout ; jargon comptable retiré ou expliqué.
- **Cohérence kit** : tarif ChatGPT Plus = ~10 000 FCFA/mois ; CRTF rappelée comme acquise ; outils présentés de façon neutre ; règle « l'IA propose, vous décidez » et code feu rouge/orange/vert cohérents avec le reste du kit.
- **Prudence chiffres et fiscalité renforcée** : aucun taux de TVA, barème ou règle DGI/SYSCOHADA n'est asséné comme une vérité ; tout renvoie à un recalcul, à un expert-comptable ou à une vérification auprès de la DGI ; l'IA ne calcule jamais un montant fiscal.
- **Exercices** : étapes détaillées, consignes de restitution et corrigés indicatifs pour l'animation.

---

## OBJECTIFS DE LA FORMATION

À l'issue de cette formation, chaque participant sera capable de :

1. **Identifier** les cas d'usage concrets de l'IA dans les fonctions comptables et financières, en distinguant ce que l'IA peut faire de ce qu'elle ne peut pas faire.
2. **Rédiger** des prompts CRTF adaptés aux tâches courantes de sa fonction (analyse, rédaction, synthèse, préparation documentaire).
3. **Évaluer** les risques spécifiques à l'usage de l'IA en comptabilité et finance : erreurs de calcul, confidentialité des données, conformité fiscale et réglementaire.
4. **Appliquer** les garde-fous essentiels et les bonnes pratiques pour un usage responsable de l'IA, en s'appuyant sur la Charte d'usage à adopter en entreprise.

---

## INTRODUCTION : POURQUOI L'IA CONCERNE LA COMPTABILITÉ ET LA FINANCE

### Ce que vous avez peut-être entendu

> *« L'IA va remplacer les comptables. »*
> *« L'IA fait les comptes à votre place. »*
> *« Il suffit de lui poser la question et elle donne la bonne réponse. »*

Ces affirmations sont **inexactes**. Cette formation existe précisément pour poser les bons repères.

### Ce que l'IA EST, concrètement

L'IA (ChatGPT, Gemini, Claude, Copilot…) est un **assistant de rédaction, d'analyse de texte et de structuration d'idées**. Elle fonctionne comme un collaborateur très cultivé qui :

- Lit et reformule des documents rapidement
- Structure des informations que vous lui fournissez
- Rédige des textes professionnels sur vos indications
- Explique des concepts complexes en langage simple
- Aide à préparer des tableaux, des modèles, des procédures

### Ce que l'IA N'EST PAS

| L'IA n'est pas… | Conséquence pratique |
|---|---|
| Une calculatrice fiable | Elle peut annoncer un résultat faux avec un ton très assuré |
| Un expert-comptable certifié | Elle peut citer une règle SYSCOHADA ou un taux DGI incorrect |
| Un coffre-fort sécurisé | Tout ce que vous tapez peut être utilisé pour entraîner le modèle |
| Un validateur de paiement | Elle ne remplace jamais une signature, un bon de paiement, un rapprochement bancaire |
| Un juriste fiscal | Elle ne connaît pas l'arrêté en vigueur hier à la DGI de Bamako |

### Pourquoi ça concerne votre métier maintenant

La comptabilité et la finance reposent sur **trois piliers** : la précision des chiffres, la conformité réglementaire, et la communication avec la direction. L'IA peut vous aider sur le troisième pilier et partiellement sur le premier — à condition de garder la main sur la vérification. Elle ne touche pas au deuxième pilier sans supervision experte.

> **La règle d'or de cette formation : l'IA propose. Vous vérifiez. Vous décidez.**

---

## PARTIE 1 — L'INTÉRÊT : 6 À 7 CAS D'USAGE CONCRETS ET MALIENS

### CAS D'USAGE 1 — Analyser des données de ventes mensuelles en FCFA et formuler des recommandations

**Contexte terrain :** Vous gérez la comptabilité d'une société de commerce général à Bamako. Chaque fin de mois, vous consolidez les ventes par produit ou par agence. Votre directeur vous demande un commentaire écrit sur les chiffres — ce n'est pas votre exercice préféré.

**Prompt CRTF complet :**

> **C — Contexte :** Je suis comptable dans une société de commerce général à Bamako. J'ai un tableau de ventes mensuelles pour les 6 derniers mois, ventilées par produit (huile, sucre, farine). Les montants sont en FCFA. Le tableau est le suivant : [coller ici votre tableau anonymisé, sans nom de client, sans RIB, sans données bancaires].
>
> **R — Rôle :** Tu es un analyste financier expérimenté, habitué aux PME commerciales en Afrique de l'Ouest.
>
> **T — Tâche :** Analyse ce tableau de ventes. Identifie les tendances principales (produits en hausse, en baisse, saisonnalité éventuelle). Formule 3 à 5 observations claires. Propose 2 ou 3 questions de réflexion que je pourrais soumettre à la direction pour orienter la décision commerciale.
>
> **F — Format :** Réponse en français. D'abord un court paragraphe de synthèse (5 lignes maximum). Ensuite une liste numérotée des observations. Enfin, les questions de réflexion en gras. Langage professionnel mais accessible à un directeur non-financier.

**Garde-fou immédiat :** Toute tendance chiffrée que l'IA formule (ex. « hausse de 18 % ») doit être recalculée par vous avant d'être communiquée. Ne jamais copier-coller directement un pourcentage produit par l'IA dans un rapport destiné à la direction.

### CAS D'USAGE 2 — Rédiger des lettres de relance d'impayés (1re et 2e relance)

**Contexte terrain :** Vous travaillez dans une entreprise de BTP à Bamako. Plusieurs clients ont des factures impayées depuis 30 et 60 jours. Rédiger ces courriers prend du temps et le ton est difficile à calibrer : ni trop agressif, ni trop mou.

**Prompt CRTF complet :**

> **C — Contexte :** Je travaille dans le service comptabilité d'une entreprise de BTP à Bamako. Un client (une société anonyme, que j'appellerai « Client X » pour cet exercice) a une facture impayée de [montant en FCFA] depuis [nombre] jours. Nous avons déjà eu un échange téléphonique sans résultat.
>
> **R — Rôle :** Tu es un rédacteur professionnel spécialisé dans la correspondance commerciale et comptable en contexte africain francophone.
>
> **T — Tâche :** Rédige deux lettres : une première relance (ton courtois, rappel simple du fait, invitation à régulariser sous 8 jours) et une deuxième relance (ton plus ferme, mention que des mesures complémentaires pourront être envisagées, sans être menaçant de façon exagérée). Laisse des espaces pour que j'insère le vrai nom de l'entreprise, la référence de la facture, le montant et la date.
>
> **F — Format :** Deux lettres séparées, format professionnel avec objet, corps, formule de politesse. Entre crochets, indiquer les éléments à personnaliser. Longueur : une page maximum chacune.

**Garde-fou immédiat :** Avant d'envoyer, relire pour vérifier que le ton correspond à votre relation avec ce client. L'IA ne connaît pas l'historique de votre relation commerciale.

### CAS D'USAGE 3 — Rédiger la synthèse et le commentaire d'un tableau de bord financier pour la direction

**Contexte terrain :** Chaque mois, le DAF d'une société hôtelière à Bamako présente un tableau de bord à la direction générale. Les chiffres sont corrects, mais la note de commentaire prend toujours beaucoup de temps à rédiger de façon claire et percutante.

**Prompt CRTF complet :**

> **C — Contexte :** Je suis DAF d'un hôtel à Bamako. Voici les indicateurs clés du tableau de bord du mois écoulé (données anonymisées, sans nom d'établissement) : chiffre d'affaires hébergement, chiffre d'affaires restauration, taux d'occupation, charges de personnel, résultat brut d'exploitation. [Coller les chiffres ici, en FCFA, sans données bancaires ni fiscales nominatives.]
>
> **R — Rôle :** Tu es un directeur financier expérimenté dans le secteur hôtelier en Afrique de l'Ouest.
>
> **T — Tâche :** Rédige une note de commentaire mensuelle à destination du directeur général. La note doit expliquer les faits marquants du mois, mettre en perspective les écarts avec le mois précédent si je t'en donne les données, et formuler 2 points d'attention et 1 point positif à souligner. Adopte un ton factuel, professionnel, orienté décision.
>
> **F — Format :** Texte rédigé (pas de liste à puces). 3 paragraphes : faits marquants / points d'attention / conclusion positive. Maximum 20 lignes. Destiné à être lu en moins de 2 minutes par un DG non-financier.

**Garde-fou immédiat :** Toute variation en pourcentage doit être recalculée par vous. La note produite est un premier jet — lisez-la entièrement avant de la signer.

### CAS D'USAGE 4 — Aider à la préparation d'un budget prévisionnel ou d'un plan de trésorerie

**Contexte terrain :** Un gestionnaire d'une ONG à Bamako doit préparer un budget prévisionnel pour un projet de 12 mois. Il connaît ses postes de dépenses, mais structurer le document et rédiger les hypothèses budgétaires lui prend beaucoup de temps.

**Prompt CRTF complet :**

> **C — Contexte :** Je suis gestionnaire financier dans une ONG basée à Bamako. Je dois préparer un budget prévisionnel sur 12 mois pour un projet d'éducation en milieu rural. Les postes principaux sont : personnel, déplacements terrain, fournitures, communication et coordination, frais généraux de structure. Je connais les montants approximatifs pour chaque poste.
>
> **R — Rôle :** Tu es un consultant en gestion financière de projets ONG, familier des bailleurs de fonds internationaux et des standards comptables des ONG en Afrique francophone.
>
> **T — Tâche :** Propose-moi : (1) une structure type pour présenter ce budget prévisionnel, avec les colonnes utiles (poste, unité, quantité, coût unitaire, total) ; (2) un exemple de note explicative des hypothèses budgétaires pour les postes « personnel » et « déplacements terrain » que je pourrai adapter ; (3) une liste de 5 questions à me poser avant de finaliser ce budget.
>
> **F — Format :** Trois sections numérotées et titrées. Pour la structure du budget, présenter sous forme de tableau. Pour les notes d'hypothèses, rédiger 2 courts paragraphes modèles. Pour les questions, liste numérotée. Langue française, format professionnel.

**Garde-fou immédiat :** L'IA propose une structure et des formulations. Tous les chiffres sont saisis et vérifiés par vous dans votre outil (Excel, etc.). Ne demandez jamais à l'IA de « calculer le total » — faites-le dans Excel.

### CAS D'USAGE 5 — Expliquer un concept comptable à un non-financier

**Contexte terrain :** Le directeur commercial d'une société de transit à Bamako ne comprend pas pourquoi le résultat comptable est positif mais la trésorerie est tendue. La DAF doit lui expliquer le décalage encaissements/décaissements. Elle cherche une formulation simple et pédagogique.

**Prompt CRTF complet :**

> **C — Contexte :** Je suis directrice administrative et financière dans une société de transit à Bamako. Je dois expliquer à notre directeur commercial — qui n'a pas de formation comptable — pourquoi une entreprise peut afficher un bénéfice comptable mais manquer de liquidités en caisse. C'est un concept que je maîtrise mais que je n'arrive pas à expliquer simplement.
>
> **R — Rôle :** Tu es un formateur en finance d'entreprise, expert en pédagogie pour les non-financiers, habitué à travailler en Afrique de l'Ouest.
>
> **T — Tâche :** Explique le décalage entre résultat comptable et trésorerie avec une analogie concrète tirée du contexte malien ou ouest-africain (commerce, marché, transport…). Donne ensuite une explication en 5 phrases claires, sans jargon comptable. Propose enfin une phrase de conclusion que je pourrai dire à l'oral lors de notre réunion.
>
> **F — Format :** Trois parties : l'analogie (3 à 4 lignes), l'explication en 5 phrases numérotées, la phrase de conclusion en italique. Pas de termes techniques sans définition immédiate.

**Garde-fou immédiat :** Lisez l'analogie avant de l'utiliser. Vérifiez qu'elle est adaptée au niveau et à la culture de votre interlocuteur. L'IA ne connaît pas votre DG.

### CAS D'USAGE 6 — Aide à la préparation documentaire d'une déclaration fiscale (sans calcul du montant)

**Contexte terrain :** Un comptable d'une société agroalimentaire à Bamako prépare la déclaration mensuelle de TVA. Il doit constituer le dossier, vérifier qu'il n'oublie aucune pièce, et préparer un mémo récapitulatif. Il ne demande pas à l'IA de calculer la TVA — cela reste son travail et celui du système comptable.

**Prompt CRTF complet :**

> **C — Contexte :** Je suis comptable dans une société agroalimentaire à Bamako. Je prépare le dossier de déclaration mensuelle de TVA à déposer auprès de la DGI. Je ne demande pas à l'IA de calculer les montants — je les calcule moi-même dans mon logiciel comptable. J'ai besoin d'aide pour la partie organisationnelle et documentaire.
>
> **R — Rôle :** Tu es un assistant organisationnel spécialisé en documentation comptable et fiscale, sans rôle d'expert fiscal.
>
> **T — Tâche :** Propose-moi : (1) une checklist générique des pièces et documents à rassembler avant de déposer une déclaration mensuelle de TVA (sans citer de montants, de taux ou de règles DGI que tu ne peux pas garantir) ; (2) un modèle de mémo interne pour informer mon supérieur que la déclaration est prête ; (3) une liste de 3 questions à poser impérativement à mon expert-comptable avant signature finale.
>
> **F — Format :** Trois sections titrées. La checklist sous forme de cases à cocher. Le mémo en format lettre courte (10 lignes max). Les questions en gras. Précise dans ta réponse que les taux et règles fiscaux doivent être vérifiés auprès de la DGI ou d'un expert-comptable.

**Garde-fou immédiat :** L'IA ne connaît pas le CGI malien en vigueur, les arrêtés DGI récents, ni les spécificités de votre régime fiscal. Elle aide à l'organisation — jamais à la décision fiscale.

### CAS D'USAGE 7 — Rédiger une note de procédure interne (notes de frais, gestion de caisse)

**Contexte terrain :** La responsable comptable d'une PME de services à Bamako veut formaliser la procédure de remboursement des notes de frais et la tenue de la caisse petite monnaie. Il n'existe pas encore de document écrit — chacun fait « à sa façon ».

**Prompt CRTF complet :**

> **C — Contexte :** Je suis responsable comptable dans une PME de services à Bamako (environ 25 salariés). Il n'existe pas de procédure écrite pour les notes de frais ni pour la gestion de la caisse petite monnaie. Chaque salarié demande les remboursements de façon informelle. Je veux mettre en place deux procédures simples et immédiatement applicables.
>
> **R — Rôle :** Tu es un consultant en organisation et procédures comptables pour PME africaines.
>
> **T — Tâche :** Rédige : (1) une procédure de remboursement des notes de frais (qui peut demander quoi, quels justificatifs, quel délai, qui valide, comment le remboursement est effectué) ; (2) une procédure de gestion de la caisse petite monnaie (montant de la caisse de base, qui tient le registre, comment on enregistre chaque sortie, comment on réapprovisionne, qui contrôle). Les procédures doivent être applicables dans une PME malienne, avec des paiements possibles en espèces ou via Orange Money/Wave.
>
> **F — Format :** Deux documents séparés, chacun avec un titre, un champ d'application, les étapes numérotées et un tableau synthétique des responsabilités (Qui fait quoi). Langage simple, direct, applicable par un non-comptable. Maximum 2 pages chacun.

**Garde-fou immédiat :** Relire les procédures pour vérifier qu'elles correspondent à la réalité de votre entreprise et au cadre légal malien (droit du travail, règles UEMOA…). Faire valider par la direction avant diffusion.

---

## PARTIE 2 — LES RISQUES : CE QUE VOUS DEVEZ ABSOLUMENT SAVOIR

### RISQUE (a) — Les erreurs de calcul et les chiffres faux présentés avec assurance

L'IA n'est pas une calculatrice. Elle génère du texte de façon probabiliste. Lorsqu'elle produit un chiffre — un total, un pourcentage, un ratio — ce chiffre peut être faux. Ce qui est dangereux, c'est qu'elle le présente avec le même ton assuré qu'une information exacte. Il n'y a pas de signal d'alarme.

**Exemple concret :** Vous collez un tableau de 12 lignes et demandez « quel est le total des ventes du trimestre ? ». Le chiffre rendu peut être erroné — une ligne oubliée, une addition incorrecte, une confusion de colonnes. Si vous le copiez dans votre rapport sans vérifier, vous présentez une information fausse à votre direction.

> **Règle sans exception :** tout chiffre produit par l'IA doit être recalculé manuellement ou dans Excel avant d'être utilisé. L'IA est excellente pour rédiger autour des chiffres ; elle ne calcule pas — vous calculez.

### RISQUE (b) — La confidentialité des données financières

Lorsque vous tapez une information dans un outil grand public, elle quitte votre ordinateur et est transmise à des serveurs à l'étranger. Selon les paramètres, elle peut être utilisée pour améliorer le modèle. Le principe de prudence s'impose.

**Ce qu'il ne faut JAMAIS saisir :**

- Numéros de comptes bancaires, RIB, IBAN
- Codes et PIN Orange Money, Wave, ou tout autre portefeuille mobile
- Bilans nominatifs complets avec le nom de l'entreprise et les chiffres réels
- Marges commerciales confidentielles
- Informations fiscales nominatives (NIF, résultats imposables réels)
- Données personnelles de salariés (salaires nominatifs, numéros CNI/NINA)
- Données de clients identifiés (contrats, montants de marchés)

> **Règle :** avant de coller quoi que ce soit, demandez-vous : « Si cette information était lue par un inconnu, est-ce un problème ? » Si oui, anonymisez : « Société X », « Client A », « Fournisseur 1 », et remplacez les montants réels sensibles par des montants fictifs de même ordre de grandeur.

### RISQUE (c) — La conformité fiscale et réglementaire

L'IA a été entraînée sur des données jusqu'à une certaine date. Elle peut citer un taux de TVA, une règle DGI, un article du Code Général des Impôts malien ou une norme SYSCOHADA/OHADA — et se tromper. Le taux peut être obsolète, la règle modifiée par un arrêté récent, la norme inapplicable à votre cas.

**Exemples de risques réels :** citer un taux de TVA sans connaître une exonération sectorielle ; décrire une procédure DGI modifiée ; évoquer une règle OHADA/SYSCOHADA sans préciser qu'elle ne s'applique pas à votre régime ; mentionner un barème de pénalité inexact.

> **Règle sans exception :** aucune décision fiscale ou réglementaire ne doit être prise sur la base d'une information fournie par l'IA sans vérification auprès de la DGI, d'un expert-comptable agréé, ou du texte officiel (CGI, textes OHADA). En matière fiscale, une erreur présentée avec assurance peut coûter très cher à l'entreprise.

### RISQUE (d) — La dépendance et la perte de maîtrise des chiffres

Si un comptable s'habitue à laisser l'IA « lire » et « analyser » les chiffres à sa place, il peut perdre le réflexe de les vérifier lui-même. La vigilance comptable — ce regard critique sur un chiffre inhabituel — s'entretient par la pratique. Un collaborateur qui ne relit plus attentivement un bilan ou un rapprochement bancaire est moins susceptible de détecter une erreur, une anomalie, voire une fraude interne.

> **Règle :** l'IA est un outil de gain de temps, pas de délégation de responsabilité. Continuez à lire vos chiffres, à poser des questions, à croiser vos états.

### RISQUE (e) — Le risque de fraude et la séparation des tâches

L'IA ne peut pas et ne doit pas être intégrée dans un circuit de validation de paiement. Un texte rédigé par l'IA peut servir à imiter un document officiel, un bon de commande, une instruction de virement.

**Situations à risque :** email rédigé par l'IA imitant le style du directeur pour demander un virement urgent ; bon de paiement généré et signé sans vérification ; procédure contournant la séparation des tâches sous prétexte d'« efficacité IA ».

> **Règle :** les circuits de validation financière (bons de paiement, ordres de virement, signatures autorisées) ne changent pas parce que l'IA existe. Si quelqu'un propose de « simplifier » ces circuits grâce à l'IA, c'est un signal d'alarme. La séparation des tâches est un contrôle interne — pas une formalité.

---

## PARTIE 3 — LES OPPORTUNITÉS : CE QUE L'IA CHANGE VRAIMENT

1. **Gain de temps sur le reporting et la rédaction** — commentaires de tableaux de bord, notes de synthèse, courriers, procédures : plusieurs heures par semaine ramenées à quelques minutes, à condition de fournir les données et de relire le résultat.
2. **Professionnalisation des PME maliennes** — produire rapidement procédures, modèles de courriers, notes de politique comptable que beaucoup de PME n'ont pas encore formalisés. Un levier de structuration à coût quasi nul.
3. **Aide à la décision et à la réflexion** — l'IA joue un rôle d'« interlocuteur de réflexion » : situation anonymisée → angles d'analyse, questions à creuser, points de vigilance. Elle ne décide pas.
4. **Communication financière plus claire vers la direction** — reformuler un message financier complexe en langage accessible, produire des résumés exécutifs, préparer une présentation orale.
5. **Détection d'anomalies à vérifier** — sur un jeu de données anonymisé, l'IA aide à formuler les bonnes questions pour repérer des écarts à approfondir. Elle ne détecte pas la fraude à votre place.
6. **Montée en compétence et formation continue** — expliquer un concept rencontré pour la première fois, préparer une formation interne, s'entraîner sur des cas pratiques, y compris sur mobile.

> **Pour les PME maliennes :** accéder à un assistant de rédaction et d'analyse de qualité — sans recruter un consultant externe — est une opportunité concrète de renforcer la fonction financière à moindre coût.

---

## PARTIE 4 — BONNES PRATIQUES & GARDE-FOUS

### Le système feu tricolore pour l'usage de l'IA en comptabilité et finance

**FEU VERT — Vous pouvez utiliser l'IA (avec relecture)**

- Rédiger des courriers, lettres de relance, mémos internes
- Reformuler un concept pour un non-financier
- Structurer une procédure ou une checklist
- Préparer un commentaire de tableau de bord (chiffres recalculés par vous)
- Générer un modèle de budget ou de plan de trésorerie (sans les montants)
- Préparer des questions pour votre expert-comptable

**FEU ORANGE — Usage possible, mais vérification obligatoire avant tout usage**

- Analyse de tendances sur des données que vous fournissez (recalculer tous les chiffres)
- Explication d'une règle comptable générale (vérifier avec SYSCOHADA ou un expert)
- Aide à la compréhension d'un texte réglementaire (confirmer avec la source officielle)
- Formulation d'une synthèse financière (relecture complète obligatoire)

**FEU ROUGE — Ne jamais faire avec l'IA**

- Saisir des données bancaires, RIB, codes Orange Money/Wave, PIN
- Demander à l'IA de calculer un montant de TVA, un impôt, une cotisation sociale
- Utiliser une réponse fiscale ou réglementaire de l'IA sans vérification DGI/expert
- Intégrer l'IA dans un circuit de validation de paiement
- Copier-coller un chiffre produit par l'IA sans le recalculer
- Saisir des données nominatives de salariés, de clients ou de partenaires

### Les 5 réflexes à adopter immédiatement

1. **Anonymiser avant de saisir** — aucune donnée nominative, bancaire ou fiscale réelle dans l'IA.
2. **Recalculer tout chiffre** — l'IA n'est pas une calculatrice fiable.
3. **Vérifier toute règle** — DGI, expert-comptable, texte officiel OHADA/SYSCOHADA.
4. **Relire avant d'envoyer** — le texte de l'IA est un premier jet, pas un document final.
5. **L'IA propose, vous décidez** — la responsabilité professionnelle reste la vôtre.

---

## PARTIE 5 — EXERCICES TERRAIN

### EXERCICE 1 — Analyser un tableau de ventes et rédiger un commentaire pour la direction

**Durée estimée :** 25 minutes — **Modalité :** Individuel ou en binôme

Voici un tableau de ventes fictif d'une société commerciale à Bamako sur 6 mois (données entièrement fictives, uniquement pour l'exercice) :

| Mois | Huile (FCFA) | Sucre (FCFA) | Farine (FCFA) | Total mensuel (FCFA) |
|---|---|---|---|---|
| Janvier | 4 200 000 | 3 100 000 | 1 800 000 | 9 100 000 |
| Février | 3 900 000 | 3 300 000 | 1 600 000 | 8 800 000 |
| Mars | 4 500 000 | 2 900 000 | 2 100 000 | 9 500 000 |
| Avril | 5 100 000 | 3 400 000 | 1 950 000 | 10 450 000 |
| Mai | 4 800 000 | 3 600 000 | 2 200 000 | 10 600 000 |
| Juin | 4 100 000 | 4 200 000 | 1 700 000 | 10 000 000 |

**Étape 1 — Avant l'IA (5 min) :** Calculez vous-même (à la main ou dans Excel) le total sur 6 mois, le mois le plus fort, et le produit avec la plus forte croissance entre janvier et juin.

**Étape 2 — Avec l'IA (10 min) :** Rédigez un prompt CRTF complet et soumettez-le à l'outil de votre choix. Demandez une analyse des tendances et un commentaire pour la direction.

**Étape 3 — Vérification critique (10 min) :** Comparez les chiffres cités par l'IA avec vos calculs de l'étape 1. Y a-t-il des écarts ? Des affirmations que vous ne pouvez pas confirmer ? Notez vos observations.

**Questions de débriefing :** L'IA a-t-elle fait des erreurs de calcul ? Le commentaire était-il directement utilisable ? Qu'auriez-vous refusé de transmettre tel quel à votre directeur ?

### EXERCICE 2 — Détecter les risques dans une demande du directeur général

**Durée estimée :** 20 minutes — **Modalité :** En groupe ou en discussion ouverte

**Mise en situation :** M. Coulibaly, directeur général d'une société de transit à Bamako, vous convoque un lundi matin :

> *« J'ai découvert ChatGPT ce week-end, c'est fantastique ! Ce soir, je veux qu'on fasse ceci : tu colles notre bilan complet avec les vrais chiffres, le nom de l'entreprise, notre NIF, et notre RIB bancaire. Ensuite tu lui demandes de calculer notre TVA collectée du trimestre et de vérifier si on est en règle avec la DGI. Et comme ça on n'a plus besoin de payer l'expert-comptable ! »*

**Questions à traiter en groupe :**

1. **Identifiez tous les risques** (minimum 4). Pour chacun : de quel type s'agit-il (confidentialité ? calcul ? réglementaire ? autre ?) et quelle conséquence concrète pour l'entreprise ?
2. **Rédigez la réponse à M. Coulibaly** — ton professionnel, respectueux, mais ferme ; expliquez pourquoi vous ne pouvez pas faire cela tel quel, et proposez une alternative utile.
3. **Rédigez un prompt CRTF alternatif** sécurisé et utile, en réponse à la préoccupation légitime du DG (connaître sa situation fiscale).

**Corrigé indicatif des risques :**

- Bilan complet + nom + NIF → confidentialité des données fiscales et comptables nominatives
- RIB bancaire → divulgation de données bancaires sensibles
- Calcul de la TVA par l'IA → erreur de calcul présentée avec assurance + décision fiscale sur base non fiable
- « Vérifier si on est en règle avec la DGI » → risque réglementaire majeur : l'IA ne connaît ni le dossier fiscal, ni les arrêtés en vigueur, ni les échanges avec la DGI
- « Ne plus payer l'expert-comptable » → perte de maîtrise et dépendance à un outil non certifié

---

## LIVRABLE — CHARTE D'USAGE DE L'IA EN COMPTABILITÉ & FINANCE (12 RÈGLES)

*La charte est fournie en document autonome (`charte-ia-compta-finance.md`) à personnaliser, adopter et afficher. Résumé des 12 règles :*

1. **L'IA est un assistant, pas un expert** — la décision et la signature restent humaines.
2. **Je recalcule tout chiffre produit par l'IA** — aucun montant copié sans recalcul.
3. **Je n'entre jamais de données bancaires** (RIB, IBAN, comptes, codes/PIN Orange Money/Wave).
4. **Je n'entre jamais de données fiscales nominatives** (NIF, bilans réels, résultats imposables).
5. **J'anonymise avant de saisir** (« Société X », « Client A », montants fictifs de même ordre).
6. **Aucune décision fiscale sur la base d'une réponse IA** sans vérification DGI/expert/SYSCOHADA.
7. **Je relis intégralement tout texte produit** avant diffusion ou signature.
8. **L'IA ne fait pas partie du circuit de validation des paiements.**
9. **Je ne partage pas les données de tiers** (clients, fournisseurs, partenaires) sans précaution.
10. **J'utilise l'IA pour préparer, pas pour décider.**
11. **Je signale tout doute ou incident** à ma hiérarchie sans délai.
12. **Je reste compétent dans mon métier** — l'IA ne remplace ni ma formation, ni mon jugement.

---

| Fonction | Nom | Date | Signature |
|---|---|---|---|
| Directeur(rice) Général(e) | | | |
| Directeur(rice) Administratif(ve) et Financier(ère) / Chef comptable | | | |
| Expert-comptable de référence (le cas échéant) | | | |

---

*Module thématique ciblé Comptabilité & Finance — Programme « IA & Productivité en entreprise », Mali. Tout contenu chiffré ou fiscal est indicatif et ne se substitue pas à un recalcul, à l'avis d'un expert-comptable agréé ou à une vérification auprès de la DGI.*
