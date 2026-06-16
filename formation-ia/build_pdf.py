#!/usr/bin/env python3
"""Convertit les fichiers Markdown du kit de formation en PDF prêts à diffuser.

Chaîne : Markdown -> HTML (python-markdown) -> PDF (WeasyPrint).
Gère les accents, les tableaux, les blocs ASCII (plans de salle, canevas) et
les césures de page propres avant chaque titre de niveau 1.

Usage : python3 build_pdf.py fichier1.md [fichier2.md ...]
Produit un .pdf A4 à côté de chaque source.
"""
import sys
from pathlib import Path
import markdown
from weasyprint import HTML

CSS = """
@page {
  size: A4; margin: 1.8cm 1.5cm;
  @bottom-center { content: "Formation IA & Productivité en entreprise — Bamako";
                   font-size: 7.5pt; color: #8a97a3; }
  @bottom-right  { content: "Page " counter(page) "/" counter(pages);
                   font-size: 7.5pt; color: #8a97a3; }
}
body { font-family: "DejaVu Sans", sans-serif; font-size: 10pt;
       line-height: 1.45; color: #1a1a1a; }
h1 { font-size: 18pt; color: #0b3d63; border-bottom: 2px solid #0b3d63;
     padding-bottom: 4px; margin: 0 0 0.5em; }
h1:not(:first-of-type) { page-break-before: always; }
h2 { font-size: 14pt; color: #105a8a; margin-top: 1.1em;
     border-bottom: 1px solid #cdd9e3; padding-bottom: 2px; }
h3 { font-size: 12pt; color: #1a6aa0; margin-top: 0.9em; }
h4 { font-size: 10.5pt; color: #333; margin-top: 0.7em; }
strong { color: #0b3d63; }
table { border-collapse: collapse; width: 100%; margin: 0.6em 0; font-size: 9pt; }
th, td { border: 1px solid #aab7c4; padding: 4px 6px; text-align: left;
         vertical-align: top; }
th { background: #e8f0f7; color: #0b3d63; }
tr:nth-child(even) td { background: #f6f9fc; }
code { font-family: "DejaVu Sans Mono", monospace; font-size: 8.7pt;
       background: #f0f2f4; padding: 1px 3px; border-radius: 3px; }
pre { font-family: "DejaVu Sans Mono", monospace; font-size: 8pt;
      line-height: 1.15; background: #f6f8fa; border: 1px solid #d0d7de;
      border-radius: 5px; padding: 8px 10px; white-space: pre;
      page-break-inside: avoid; }
pre code { background: none; padding: 0; font-size: 8pt; }
blockquote { border-left: 4px solid #1a6aa0; margin: 0.5em 0; padding: 2px 12px;
             background: #eef4f9; color: #21404f; font-style: italic; }
hr { border: none; border-top: 1px solid #cdd9e3; margin: 1em 0; }
ul, ol { margin: 0.4em 0; padding-left: 1.3em; }
table, pre, blockquote, h2, h3 { page-break-inside: avoid; }
"""

TMPL = '<!DOCTYPE html><html lang="fr"><head><meta charset="utf-8">' \
       '<style>{css}</style></head><body>{body}</body></html>'


def convert(md_path: Path):
    body = markdown.markdown(
        md_path.read_text(encoding="utf-8"),
        extensions=["tables", "fenced_code", "sane_lists"],
    )
    html = TMPL.format(css=CSS, body=body)
    pdf_path = md_path.with_suffix(".pdf")
    HTML(string=html).write_pdf(str(pdf_path))
    print(f"  {md_path.name}  ->  {pdf_path.name}  "
          f"({pdf_path.stat().st_size // 1024} Ko)")


if __name__ == "__main__":
    for arg in sys.argv[1:]:
        convert(Path(arg))
