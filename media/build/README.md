# Génération du PDF de validation

Le PDF `Dossier-Media-KUMA-Episode-01.pdf` compile tout le système éditorial
(`media/*.md`) + l'épisode 01 (`media/episodes/episode-boubacar-traore.md` et
`ep01-boubacar-production.md`) en un document présentable.

## Régénérer
```bash
python3 -m venv /tmp/pdfvenv
/tmp/pdfvenv/bin/pip install markdown xhtml2pdf
/tmp/pdfvenv/bin/python media/build/build_pdf.py
```
Sortie : `media/build/Dossier-Media-KUMA-Episode-01.pdf`.

Pour mettre à jour le contenu, éditer les `.md` puis relancer le script.
Le nom du média est en stand-by : remplacer « KUMA » dans `build_pdf.py`
(couverture + pied de page) une fois le nom validé.
