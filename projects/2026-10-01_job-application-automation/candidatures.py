#!/usr/bin/env python3
"""Envoi automatisé et fiable de candidatures par email.

Principes de fiabilité :
  - validation humaine : seules les lignes avec valide=oui sont envoyées
  - idempotence       : registre SQLite, jamais deux envois pour (email, poste)
  - garde-fous        : dry-run par défaut, quota journalier, délai entre envois
  - robustesse        : retry avec backoff sur erreurs SMTP temporaires, verrou anti-double exécution
  - traçabilité       : logs fichier + résumé Slack optionnel
"""

import argparse
import csv
import fcntl
import hashlib
import json
import logging
import os
import re
import smtplib
import socket
import sqlite3
import sys
import time
import tomllib
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timedelta
from email.message import EmailMessage
from email.utils import formatdate, make_msgid
from pathlib import Path
from string import Template

BASE_DIR = Path(__file__).resolve().parent
EMAIL_RE = re.compile(r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$")
REQUIRED_COLUMNS = {"entreprise", "poste", "email", "template", "valide"}
MAX_ATTACHMENT_BYTES = 5 * 1024 * 1024
TRANSIENT_SMTP_CODES = {421, 450, 451, 452}

log = logging.getLogger("candidatures")


@dataclass
class Candidature:
    entreprise: str
    poste: str
    email: str
    template: str
    valide: str
    contact: str = ""
    url_offre: str = ""
    accroche: str = ""

    @property
    def key(self) -> str:
        raw = f"{self.email.strip().lower()}|{self.poste.strip().lower()}"
        return hashlib.sha256(raw.encode()).hexdigest()[:16]


# --------------------------------------------------------------------------- config

def load_config(path: Path) -> dict:
    with open(path, "rb") as f:
        cfg = tomllib.load(f)
    cfg["smtp"]["password"] = os.environ.get(cfg["smtp"].get("password_env", "SMTP_PASSWORD"), "")
    cfg.setdefault("slack", {})["webhook"] = os.environ.get(
        cfg["slack"].get("webhook_env", "SLACK_WEBHOOK_URL"), "")
    return cfg


def setup_logging(log_file: Path, verbose: bool) -> None:
    log_file.parent.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(
        level=logging.DEBUG if verbose else logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        handlers=[logging.FileHandler(log_file), logging.StreamHandler()],
        force=True,
    )


# --------------------------------------------------------------------------- registre

def open_db(path: Path) -> sqlite3.Connection:
    path.parent.mkdir(parents=True, exist_ok=True)
    db = sqlite3.connect(path)
    db.execute("""
        CREATE TABLE IF NOT EXISTS envois (
            key TEXT PRIMARY KEY,
            entreprise TEXT, poste TEXT, email TEXT,
            statut TEXT NOT NULL,           -- envoye | echec | relance
            message_id TEXT,
            envoye_le TEXT,
            relance_le TEXT,
            erreur TEXT
        )""")
    db.commit()
    return db


def already_sent(db: sqlite3.Connection, key: str) -> bool:
    row = db.execute("SELECT statut FROM envois WHERE key=?", (key,)).fetchone()
    return row is not None and row[0] in ("envoye", "relance")


def sent_today(db: sqlite3.Connection) -> int:
    today = datetime.now().date().isoformat()
    return db.execute(
        "SELECT COUNT(*) FROM envois WHERE substr(envoye_le,1,10)=? OR substr(relance_le,1,10)=?",
        (today, today)).fetchone()[0]


def record(db, c: Candidature, statut: str, message_id: str = "", erreur: str = "") -> None:
    now = datetime.now().isoformat(timespec="seconds")
    db.execute("""
        INSERT INTO envois (key, entreprise, poste, email, statut, message_id, envoye_le, erreur)
        VALUES (?,?,?,?,?,?,?,?)
        ON CONFLICT(key) DO UPDATE SET statut=excluded.statut, message_id=excluded.message_id,
            envoye_le=excluded.envoye_le, erreur=excluded.erreur
    """, (c.key, c.entreprise, c.poste, c.email, statut, message_id,
          now if statut == "envoye" else None, erreur))
    db.commit()


# --------------------------------------------------------------------------- validation

def load_candidatures(path: Path) -> list[Candidature]:
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        missing = REQUIRED_COLUMNS - set(reader.fieldnames or [])
        if missing:
            raise SystemExit(f"Colonnes manquantes dans {path}: {', '.join(sorted(missing))}")
        fields = Candidature.__dataclass_fields__
        return [Candidature(**{k: (v or "").strip() for k, v in row.items() if k in fields})
                for row in reader]


def domain_resolves(email: str) -> bool:
    """Vérifie que le domaine a un MX (dnspython) ou au moins une résolution DNS."""
    domain = email.rsplit("@", 1)[-1]
    try:
        import dns.resolver  # optionnel
        try:
            return bool(dns.resolver.resolve(domain, "MX", lifetime=5))
        except Exception:
            return False
    except ImportError:
        try:
            socket.getaddrinfo(domain, None)
            return True
        except socket.gaierror:
            return False


def validate(c: Candidature, cfg: dict, check_dns: bool = True) -> list[str]:
    errors = []
    if not c.entreprise or not c.poste:
        errors.append("entreprise/poste vide")
    if not EMAIL_RE.match(c.email):
        errors.append(f"email invalide: {c.email!r}")
    elif check_dns and not domain_resolves(c.email):
        errors.append(f"domaine sans MX/DNS: {c.email.rsplit('@', 1)[-1]}")
    domain = c.email.rsplit("@", 1)[-1].lower()
    if domain in {d.lower() for d in cfg["envoi"].get("domaines_bloques", [])}:
        errors.append(f"domaine bloqué: {domain}")
    tpl = BASE_DIR / "templates" / f"{c.template}.txt"
    if not tpl.exists():
        errors.append(f"template introuvable: {tpl.name}")
    else:
        try:
            render(tpl, c, cfg)
        except KeyError as e:
            errors.append(f"variable inconnue dans le template: {e}")
    for att in cfg["candidat"].get("pieces_jointes", []):
        p = (BASE_DIR / att)
        if not p.exists():
            errors.append(f"pièce jointe manquante: {att}")
        elif p.stat().st_size > MAX_ATTACHMENT_BYTES:
            errors.append(f"pièce jointe > 5 Mo: {att}")
    return errors


# --------------------------------------------------------------------------- message

def render(tpl_path: Path, c: Candidature, cfg: dict) -> tuple[str, str]:
    """Retourne (sujet, corps). La 1re ligne du template est 'Subject: ...'."""
    cand = cfg["candidat"]
    values = {
        "entreprise": c.entreprise, "poste": c.poste, "url_offre": c.url_offre,
        "contact": c.contact or "Madame, Monsieur",
        "accroche": c.accroche,
        "nom": cand["nom"], "telephone": cand.get("telephone", ""),
        "linkedin": cand.get("linkedin", ""), "github": cand.get("github", ""),
    }
    text = Template(tpl_path.read_text(encoding="utf-8")).substitute(values)
    first, _, body = text.partition("\n")
    if not first.lower().startswith("subject:"):
        raise KeyError("première ligne 'Subject:' absente")
    return first.split(":", 1)[1].strip(), body.lstrip("\n")


def build_message(c: Candidature, cfg: dict) -> EmailMessage:
    subject, body = render(BASE_DIR / "templates" / f"{c.template}.txt", c, cfg)
    cand = cfg["candidat"]
    msg = EmailMessage()
    msg["From"] = f'{cand["nom"]} <{cand["email"]}>'
    msg["To"] = c.email
    msg["Subject"] = subject
    msg["Date"] = formatdate(localtime=True)
    msg["Message-ID"] = make_msgid(domain=cand["email"].split("@")[-1])
    if cand.get("bcc_soi_meme", True):
        msg["Bcc"] = cand["email"]  # copie dans sa propre boîte = preuve d'envoi
    msg.set_content(body)
    for att in cand.get("pieces_jointes", []):
        p = BASE_DIR / att
        msg.add_attachment(p.read_bytes(), maintype="application",
                           subtype="pdf" if p.suffix == ".pdf" else "octet-stream",
                           filename=p.name)
    return msg


def smtp_send(msg: EmailMessage, cfg: dict, retries: int = 3) -> None:
    s = cfg["smtp"]
    if not s["password"]:
        raise SystemExit(f"Variable d'environnement {s.get('password_env', 'SMTP_PASSWORD')} absente")
    for attempt in range(1, retries + 1):
        try:
            with smtplib.SMTP(s["host"], s.get("port", 587), timeout=30) as smtp:
                smtp.starttls()
                smtp.login(s["user"], s["password"])
                smtp.send_message(msg)
            return
        except smtplib.SMTPResponseException as e:
            if e.smtp_code not in TRANSIENT_SMTP_CODES or attempt == retries:
                raise
            wait = 2 ** attempt
        except (smtplib.SMTPServerDisconnected, ConnectionError, socket.timeout):
            if attempt == retries:
                raise
            wait = 2 ** attempt
        log.warning("Erreur SMTP temporaire, nouvel essai dans %ss (%d/%d)", wait, attempt, retries)
        time.sleep(wait)


def notify_slack(cfg: dict, text: str) -> None:
    url = cfg["slack"].get("webhook")
    if not url:
        return
    try:
        req = urllib.request.Request(url, data=json.dumps({"text": text}).encode(),
                                     headers={"Content-Type": "application/json"})
        urllib.request.urlopen(req, timeout=10)
    except Exception as e:  # la notif ne doit jamais faire échouer l'envoi
        log.warning("Notification Slack échouée: %s", e)


# --------------------------------------------------------------------------- commandes

def cmd_validate(args, cfg, db) -> int:
    rows = load_candidatures(args.csv)
    ko = 0
    for c in rows:
        errs = validate(c, cfg, check_dns=not args.no_dns)
        state = "DEJA ENVOYEE" if already_sent(db, c.key) else ("OK" if not errs else "KO")
        if errs:
            ko += 1
        print(f"[{state:12}] {c.entreprise} — {c.poste} <{c.email}> valide={c.valide}")
        for e in errs:
            print(f"               ↳ {e}")
    print(f"\n{len(rows)} lignes, {ko} en erreur")
    return 1 if ko else 0


def cmd_preview(args, cfg, db) -> int:
    for c in load_candidatures(args.csv):
        if args.entreprise and c.entreprise.lower() != args.entreprise.lower():
            continue
        msg = build_message(c, cfg)
        print("=" * 72)
        for h in ("From", "To", "Subject"):
            print(f"{h}: {msg[h]}")
        print("-" * 72)
        print(msg.get_body(("plain",)).get_content())
    return 0


def cmd_send(args, cfg, db) -> int:
    env = cfg["envoi"]
    quota = env.get("quota_journalier", 10) - sent_today(db)
    dry = not args.confirm
    sent, skipped, failed = [], 0, []
    for c in load_candidatures(args.csv):
        if c.valide.lower() not in ("oui", "yes", "1", "x"):
            skipped += 1
            continue
        if already_sent(db, c.key):
            log.info("Déjà envoyée, ignorée: %s — %s", c.entreprise, c.poste)
            skipped += 1
            continue
        errs = validate(c, cfg, check_dns=not args.no_dns)
        if errs:
            log.error("Invalide, ignorée: %s — %s : %s", c.entreprise, c.poste, "; ".join(errs))
            failed.append(f"{c.entreprise} ({errs[0]})")
            continue
        if len(sent) >= quota:
            log.warning("Quota journalier atteint (%d), arrêt.", env.get("quota_journalier", 10))
            break
        msg = build_message(c, cfg)
        if dry:
            log.info("[DRY-RUN] enverrait à %s : %s", c.email, msg["Subject"])
            sent.append(c.entreprise)
            continue
        if sent:
            time.sleep(env.get("delai_secondes", 120))
        try:
            smtp_send(msg, cfg)
            record(db, c, "envoye", msg["Message-ID"])
            log.info("Envoyée: %s — %s <%s>", c.entreprise, c.poste, c.email)
            sent.append(c.entreprise)
        except Exception as e:
            record(db, c, "echec", erreur=str(e))
            log.error("Échec: %s — %s : %s", c.entreprise, c.poste, e)
            failed.append(f"{c.entreprise} ({e})")
    summary = (f"{'[DRY-RUN] ' if dry else ''}Candidatures : {len(sent)} envoyée(s), "
               f"{skipped} ignorée(s), {len(failed)} échec(s)")
    if sent:
        summary += "\n✅ " + ", ".join(sent)
    if failed:
        summary += "\n❌ " + ", ".join(failed)
    log.info(summary.replace("\n", " | "))
    if not dry:
        notify_slack(cfg, summary)
    if dry:
        print("\nMode simulation. Ajoutez --confirm pour envoyer réellement.")
    return 1 if failed else 0


def cmd_status(args, cfg, db) -> int:
    rows = db.execute("SELECT envoye_le, statut, entreprise, poste, email, relance_le "
                      "FROM envois ORDER BY envoye_le DESC").fetchall()
    for r in rows:
        print(f"{r[0] or '-':19}  {r[1]:8}  {r[2]} — {r[3]} <{r[4]}>"
              + (f"  (relancée {r[5]})" if r[5] else ""))
    print(f"\n{len(rows)} entrée(s), {sent_today(db)} envoi(s) aujourd'hui")
    return 0


def cmd_relances(args, cfg, db) -> int:
    """Liste les candidatures sans réponse depuis N jours (relance manuelle ou --confirm)."""
    days = cfg["envoi"].get("relance_apres_jours", 10)
    limit = (datetime.now() - timedelta(days=days)).isoformat()
    rows = db.execute("SELECT key, entreprise, poste, email, message_id FROM envois "
                      "WHERE statut='envoye' AND envoye_le < ? AND relance_le IS NULL",
                      (limit,)).fetchall()
    tpl = BASE_DIR / "templates" / "relance.txt"
    for key, entreprise, poste, email, msg_id in rows:
        c = Candidature(entreprise, poste, email, "relance", "oui")
        if not args.confirm:
            print(f"À relancer : {entreprise} — {poste} <{email}>")
            continue
        subject, body = render(tpl, c, cfg)
        msg = build_message(c, cfg)
        msg.replace_header("Subject", subject)
        msg["In-Reply-To"] = msg["References"] = msg_id  # même fil de discussion
        msg.clear_content()
        msg.set_content(body)
        smtp_send(msg, cfg)
        now = datetime.now().isoformat(timespec="seconds")
        db.execute("UPDATE envois SET statut='relance', relance_le=? WHERE key=?", (now, key))
        db.commit()
        log.info("Relance envoyée: %s — %s", entreprise, poste)
        time.sleep(cfg["envoi"].get("delai_secondes", 120))
    print(f"{len(rows)} candidature(s) à relancer (> {days} jours)")
    return 0


def main(argv=None) -> int:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("-c", "--config", type=Path, default=BASE_DIR / "config.toml")
    p.add_argument("--csv", type=Path, default=BASE_DIR / "candidatures.csv")
    p.add_argument("-v", "--verbose", action="store_true")
    p.add_argument("--no-dns", action="store_true", help="ne pas vérifier les MX")
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("validate", help="vérifier le CSV, templates et pièces jointes")
    pv = sub.add_parser("preview", help="afficher les emails générés")
    pv.add_argument("--entreprise")
    ps = sub.add_parser("send", help="envoyer les candidatures validées")
    ps.add_argument("--confirm", action="store_true", help="envoi réel (sinon dry-run)")
    sub.add_parser("status", help="historique des envois")
    pr = sub.add_parser("relances", help="candidatures à relancer")
    pr.add_argument("--confirm", action="store_true")
    args = p.parse_args(argv)

    cfg = load_config(args.config)
    data_dir = BASE_DIR / cfg["envoi"].get("data_dir", "data")
    setup_logging(data_dir / "candidatures.log", args.verbose)

    handlers = {"validate": cmd_validate, "preview": cmd_preview, "send": cmd_send,
                "status": cmd_status, "relances": cmd_relances}
    with open(data_dir / ".lock", "w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            log.error("Une autre exécution est en cours, abandon.")
            return 2
        db = open_db(data_dir / "envois.db")
        try:
            return handlers[args.cmd](args, cfg, db)
        finally:
            db.close()
            logging.shutdown()


if __name__ == "__main__":
    sys.exit(main())
