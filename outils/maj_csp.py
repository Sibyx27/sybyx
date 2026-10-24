#!/usr/bin/env python3
"""Pose le verrou de sécurité (Content-Security-Policy) des applis de gestion.

Seuls les scripts écrits dans la page, reconnus par leur empreinte SHA-256, peuvent s'exécuter :
un script glissé par un lien piégé ou un fichier piégé est refusé par le navigateur.
L'appli n'a aucun droit d'envoyer des données sur internet (connect-src 'none', img-src 'self').

À relancer après CHAQUE modification d'un <script> :  python3 outils/maj_csp.py
"""
import base64, hashlib, pathlib, re, sys

RACINE = pathlib.Path(__file__).resolve().parent.parent
PAGES = {
    "bbs/index.html": "default-src 'none'; script-src {h}; worker-src 'self'; manifest-src 'self'; style-src 'self' 'unsafe-inline'; "
                      "img-src 'self' data: blob:; font-src 'self'; connect-src 'none'; media-src 'none'; object-src 'none'; base-uri 'none'; form-action 'none'",
    "bbs/carte.html": "default-src 'none'; script-src {h}; style-src 'unsafe-inline'; font-src 'self'; img-src 'self'; connect-src 'none'; object-src 'none'; base-uri 'none'; form-action 'none'",
    "bbs/reserver.html": "default-src 'none'; script-src {h}; style-src 'unsafe-inline'; font-src 'self'; img-src 'self'; connect-src 'none'; object-src 'none'; base-uri 'none'; form-action 'none'",
}
META = re.compile(r'(<meta http-equiv="Content-Security-Policy" content=")[^"]*(">)')

for rel, modele in PAGES.items():
    f = RACINE / rel
    html = f.read_text(encoding="utf-8")
    scripts = re.findall(r"<script>(.*?)</script>", html, flags=re.S)
    if re.search(r"<script\s+[^>]*src=", html):
        sys.exit(f"{rel} : script externe interdit")
    hors_scripts = re.sub(r"<script>.*?</script>", "", html, flags=re.S)
    if re.search(r"""<[^>]*\son[a-z]+\s*=\s*["']""", hors_scripts):
        sys.exit(f"{rel} : attribut on…= interdit (utiliser addEventListener)")
    empreintes = " ".join("'sha256-%s'" % base64.b64encode(hashlib.sha256(x.encode("utf-8")).digest()).decode() for x in scripts)
    if not META.search(html):
        sys.exit(f"{rel} : balise CSP absente")
    html = META.sub(lambda m: m.group(1) + modele.format(h=empreintes) + m.group(2), html, count=1)
    f.write_text(html, encoding="utf-8")
    print(f"{rel} : {len(scripts)} script(s) verrouillé(s)")
