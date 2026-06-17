#!/usr/bin/env python3
import os, markdown
from xhtml2pdf import pisa

BASE = "/home/user/sybyx/media"
OUT_HTML = "/home/user/sybyx/media/build/dossier-media.html"
OUT_PDF  = "/home/user/sybyx/media/build/Dossier-Media-KUMA-Episode-01.pdf"
os.makedirs(os.path.dirname(OUT_HTML), exist_ok=True)

# Ordered document list: (file, section title for TOC)
DOCS = [
    ("00-strategie-globale.md",        "00 · Stratégie globale"),
    ("01-ligne-editoriale.md",         "01 · Ligne éditoriale & charte de marque"),
    ("02-grille-evaluation-invites.md","02 · Grille d'évaluation des invités"),
    ("03-template-dossier-invite.md",  "03 · Template dossier invité"),
    ("04-structure-interview.md",      "04 · Architecture d'interview (10 parties)"),
    ("05-charte-intervieweurs.md",     "05 · Charte des intervieweurs"),
    ("06-grille-qualite-episode.md",   "06 · Grille qualité épisode"),
    ("07-checklist-mali.md",           "07 · Checklist Mali & Afrique"),
    ("08-playbook-croissance.md",      "08 · Playbook croissance & monétisation"),
    ("episodes/episode-boubacar-traore.md", "Épisode 01 — Boubacar Traoré · fiche éditoriale"),
    ("episodes/ep01-boubacar-production.md","Épisode 01 — Boubacar Traoré · dossier de production"),
]

# Replace emojis (LibreOffice fonts won't render them) with print-safe text
EMOJI = {
    "🚀":"", "⭐":" * ", "✅":"OUI", "❌":"NON", "🟢":"VERT", "🟠":"ORANGE",
    "🔴":"ROUGE", "⚠️":"ATTENTION —", "⚠":"ATTENTION —", "➡️":"=>", "✔":"",
    "🌟":" * ", "⓿":"0.", "①":"1.", "②":"2.", "③":"3.", "④":"4.", "⑤":"5.",
    "⑥":"6.", "⑦":"7.", "⑧":"8.", "⑨":"9.",
    # symbols Helvetica/WinAnsi cannot encode
    "→":"->", "←":"<-", "↔":"<->", "≥":">=", "≤":"<=", "★":"*",
}
def clean(t):
    for k,v in EMOJI.items():
        t = t.replace(k, v)
    return t

md = markdown.Markdown(extensions=["tables","fenced_code","sane_lists"])

sections = []
for fn, title in DOCS:
    with open(os.path.join(BASE, fn), encoding="utf-8") as f:
        raw = clean(f.read())
    md.reset()
    html = md.convert(raw)
    sections.append(f'<div class="doc">{html}</div>')

toc_items = "\n".join(f'<li>{t}</li>' for _, t in DOCS)

CSS = """
@page { size: a4; margin: 1.8cm;
        @frame footer { -pdf-frame-content: footerId; bottom:1cm; height:1cm; left:1.8cm; width:17.4cm; } }
body { font-family: Helvetica, sans-serif; font-size: 10pt; line-height: 1.4; color:#1a1a1a; }
.footer { color:#999; font-size:8pt; text-align:center; }
.cover { text-align:center; }
.cover .kicker { color:#B68A2E; font-size:11pt; margin-top:6cm;}
.cover h1 { color:#0E2240; font-size:28pt; margin:0.4cm 0; }
.cover .sub { font-size:13pt; color:#444; }
.cover .meta { margin-top:4cm; font-size:10pt; color:#555; }
.cover .rule { margin:0.5cm 25%; border-bottom:2px solid #B68A2E; }
.toc { page-break-before: always; }
.toc h2 { color:#0E2240; border-bottom:2px solid #B68A2E; padding-bottom:6px; }
.toc ol { font-size:11pt; }
.toc li { margin:7px 0; }
.doc { page-break-before: always; }
h1 { color:#0E2240; font-size:17pt; border-bottom:2px solid #0E2240; padding-bottom:5px; }
h2 { color:#0E2240; font-size:13pt; margin-top:16px; border-left:4px solid #B68A2E; padding-left:7px; }
h3 { color:#23344d; font-size:11pt; margin-top:12px; }
table { width:100%; margin:9px 0; font-size:8.5pt; }
th { background:#0E2240; color:#ffffff; text-align:left; padding:4px 6px; }
td { border:0.5pt solid #c9c9c9; padding:3px 6px; }
blockquote { border-left:4px solid #B68A2E; background:#faf6ee; margin:9px 0; padding:6px 12px; color:#333; }
code { background:#eef1f5; font-family:Courier; font-size:9pt; }
pre { background:#f4f6f9; border:0.5pt solid #d7dde6; padding:8px; font-size:8pt; font-family:Courier; }
ul,ol { margin:5px 0 5px 16px; }
li { margin:2px 0; }
hr { border-top:0.5pt solid #d0d0d0; margin:12px 0; }
strong { color:#0E2240; }
"""

cover = """
<div class="cover">
  <div class="kicker">Cabinet conseil média · Document de validation</div>
  <h1>Média vidéo premium — Mali</h1>
  <div class="rule"></div>
  <div class="sub">Système éditorial &amp; stratégique + Épisode 01</div>
  <div class="sub" style="font-size:11pt;color:#888;margin-top:8px;">
    Interviews longues · Documentaires · Conversations de fond<br/>
    Ambition : référence de l'Afrique francophone
  </div>
  <div class="meta">
    Nom de travail : <strong>KUMA</strong> (« la parole ») — à valider<br/>
    Version du 17 juin 2026 · Confidentiel
  </div>
</div>
"""

toc = f'<div class="toc"><h2>Sommaire</h2><ol>{toc_items}</ol></div>'

footer = '<div id="footerId" class="footer">Média premium Mali — KUMA (nom de travail) · Document de validation · 17/06/2026 · Confidentiel</div>'
doc = f"""<!DOCTYPE html><html lang="fr"><head><meta charset="utf-8">
<style>{CSS}</style></head><body>{footer}{cover}{toc}{''.join(sections)}</body></html>"""

with open(OUT_HTML, "w", encoding="utf-8") as f:
    f.write(doc)
print("HTML written:", OUT_HTML, os.path.getsize(OUT_HTML), "bytes")

with open(OUT_PDF, "wb") as out:
    res = pisa.CreatePDF(doc, dest=out, encoding="utf-8")
print("PDF errors:", res.err)
print("PDF written:", OUT_PDF, os.path.getsize(OUT_PDF), "bytes")
