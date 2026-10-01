# 📨 Automatisation fiable des candidatures

Outil Python (bibliothèque standard uniquement) qui envoie des candidatures personnalisées par email, **sans spam, sans doublon et avec traçabilité**.

## Ce qui rend l'envoi fiable

| Risque | Garde-fou |
|---|---|
| Envoyer une candidature non relue | Colonne `valide` : seules les lignes à `oui` partent |
| Envoyer deux fois au même recruteur | Registre SQLite `data/envois.db` (clé = email + poste) |
| Partir par erreur | **Dry-run par défaut**, `--confirm` obligatoire pour l'envoi réel |
| Être classé spam / bloqué par Gmail | Quota journalier (10) et délai entre envois (120 s) |
| Adresse fausse ou domaine mort | Validation du format et du MX (DNS) |
| Template cassé, CV oublié | `validate` vérifie variables, pièces jointes et taille (≤ 5 Mo) |
| Panne SMTP temporaire | Retry avec backoff exponentiel (codes 421/45x) |
| Deux exécutions en même temps | Verrou `flock` |
| « Est-ce que c'est vraiment parti ? » | Log fichier, copie Bcc dans votre boîte, résumé Slack |
| Fuite de secrets | Mot de passe via variable d'env, `config.toml`/CSV/CV ignorés par git |

## Installation

```bash
cp config.example.toml config.toml          # vos infos
cp candidatures.example.csv candidatures.csv
cp ~/Documents/CV.pdf cv/CV_Jaouad_DevOps.pdf

# Gmail : créer un mot de passe d'application (compte Google → Sécurité → 2FA → Mots de passe des applications)
export SMTP_PASSWORD='xxxx xxxx xxxx xxxx'
export SLACK_WEBHOOK_URL='https://hooks.slack.com/services/...'   # optionnel
pip install dnspython                                           # optionnel, vérification MX réelle
```

## Le flux de travail

```bash
# 1. Ajouter des offres dans candidatures.csv (valide=non), avec une accroche personnalisée
# 2. Contrôler
./candidatures.py validate
./candidatures.py preview --entreprise "Exemple SAS"
# 3. Passer valide=oui sur les lignes relues
# 4. Simuler puis envoyer
./candidatures.py send
./candidatures.py send --confirm
# 5. Suivre
./candidatures.py status
./candidatures.py relances            # liste les candidatures sans réponse depuis 10 jours
./candidatures.py relances --confirm  # envoie la relance dans le même fil (In-Reply-To)
```

### Format du CSV

| Colonne | Obligatoire | Rôle |
|---|---|---|
| `entreprise`, `poste`, `email` | ✅ | Destinataire |
| `template` | ✅ | Nom d'un fichier dans `templates/` (`devops`, `linux`…) |
| `valide` | ✅ | `oui` = relu, prêt à partir |
| `contact` | | « Madame Martin » (sinon « Madame, Monsieur ») |
| `url_offre`, `accroche` | | Personnalisation : une phrase spécifique à l'entreprise fait toute la différence |

Les templates utilisent `$variable` ; la 1re ligne doit être `Subject: ...`.

## Automatisation (systemd timer)

```bash
mkdir -p ~/candidatures && cp -r . ~/candidatures
printf 'SMTP_PASSWORD=...\nSLACK_WEBHOOK_URL=...\n' > ~/.config/candidatures.env && chmod 600 ~/.config/candidatures.env
cp systemd/candidatures.{service,timer} ~/.config/systemd/user/
systemctl --user daemon-reload && systemctl --user enable --now candidatures.timer
systemctl --user list-timers ; journalctl --user -u candidatures -f
```

Envoi en semaine à 9 h (± 15 min). Vous n'avez plus qu'à passer des lignes à `valide=oui`.

## Tests

```bash
python3 -m unittest discover -s tests -v
```

## ⚠️ Bonnes pratiques

- Écrivez à des adresses publiées pour recruter (offre, page carrières), pas à des adresses collectées en masse : c'est aussi une question de RGPD.
- Pour les offres qui passent par un formulaire (Welcome to the Jungle, Indeed, France Travail…), postulez sur la plateforme. Ce script ne gère que l'email direct.
- Une candidature personnalisée vaut mieux que dix envois génériques. Gardez le quota bas.
