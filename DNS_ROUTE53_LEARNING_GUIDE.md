# Guide Complet : DNS & Route53 sur AWS
**Formation DevOps/SRE - Jaouad 2026**

---

## Table des matières
1. [Concepts Fondamentaux DNS](#concepts-fondamentaux)
2. [Route53 sur AWS](#route53-aws)
3. [Types de Records DNS](#types-records)
4. [Architecture Infrastructure](#architecture)
5. [Configuration Complète](#configuration)
6. [Validation et Tests](#validation)

---

## Concepts Fondamentaux DNS

### Qu'est-ce que le DNS ?

Le **Domain Name System** est le "annuaire téléphonique d'Internet". Il traduit les noms de domaine lisibles (exemple.com) en adresses IP (192.0.2.1) que les ordinateurs comprennent.

```
Utilisateur tape : api.domaine.com
        ↓ (requête DNS)
Résolveur récursif (ISP, 8.8.8.8)
        ↓
Root Nameserver (.com, .fr, etc)
        ↓
Authoritative Nameserver (Route53)
        ↓
Réponse : 203.0.113.42
        ↓
Navigateur se connecte à 203.0.113.42
```

### Les 3 acteurs clés

| Acteur | Rôle | Exemple |
|--------|------|---------|
| **Root Nameserver** | Dirige vers le TLD | `.com`, `.fr` |
| **TLD Nameserver** | Dirige vers la zone autoritaire | VIZ par `domaine.com` |
| **Authoritative Nameserver** | Répond avec les vrais records | AWS Route53 |

### Résolveur récursif vs Autoritaire

```
RÉCURSIF (Resolver):
- Fait toute la recherche pour vous
- Cache les résultats
- Exemple: 8.8.8.8, 1.1.1.1, AWS Route53 Resolver

AUTORITAIRE (Authoritative):
- Contient les vrais records
- Route53, Cloudflare, GoDaddy
- Répond "voici la vraie réponse"
```

### Zones DNS

Une **zone** est un domaine et tous ses sous-domaines (sauf délégués).

```
Zone domaine.com :
├── domaine.com
├── api.domaine.com
├── admin.domaine.com
├── internal.domaine.com
├── cdn.domaine.com
└── *.domaine.com (wildcard)
```

**Délégation :** vous pouvez créer une sous-zone gérée séparément

```
domaine.com  (Zone Route53)
├── ns.prod.domaine.com ← Délégué vers Route53 différent ou autre registrar
└── ns.backup.domaine.com ← Autre registrar
```

### TTL (Time To Live)

Le TTL définit **combien de temps** on peut mettre en cache une réponse DNS.

```
TTL = 300 (5 minutes)
```

| Valeur | Usage | Cas d'usage |
|--------|-------|------------|
| 60 | Très court | Migration, changement rapide |
| 300 | Court (défaut) | Production générale |
| 3600 | 1 heure | Services stables |
| 86400 | 1 jour | Rarement changé |

**Stratégie pour cette infra :**
- API endpoint (change souvent) : TTL 300s
- Bastion (stable) : TTL 3600s
- Services internes (très stables) : TTL 3600s

---

## Route53 sur AWS

### Qu'est-ce que Route53 ?

Route53 est le service DNS managed d'AWS qui :
- ✅ Gère vos zones DNS (autoritaire)
- ✅ Supporte plusieurs types de routing intelligent
- ✅ Intégré avec AWS (ALB, EC2, Lambda, etc)
- ✅ Haute disponibilité (pas de SPOF)
- ✅ Monitoring avec CloudWatch

### Architecture Route53

```
Internet utilisateurs
        ↓
8.8.8.8 (Resolver récursif)
        ↓
.com TLD Nameserver
        ↓
Route53 Nameserver (AWS-managed)
        ↓
Zone domaine.com (Route53)
        ↓
Recordsets:
  ├── A records
  ├── CNAME
  ├── Alias (AWS spécifique)
  └── MX, TXT, SRV, etc
```

### Registrar vs DNS Service

| Aspect | Registrar | DNS Service |
|--------|-----------|-------------|
| **Rôle** | Enregistre le domaine | Gère les records |
| **Exemple** | Godaddy, Namecheap | Route53, Cloudflare |
| **Relation** | ← pointe vers → | Contient les données |
| **Pour cette infra** | GoDaddy (domaine.com) | AWS Route53 |

```
Workflow:
1. Acheter domaine.com chez GoDaddy
2. Créer zone domaine.com dans Route53
3. Copier NS records Route53 → GoDaddy
4. Route53 répond à toutes les requêtes DNS pour domaine.com
```

### Types de Routing Route53

Route53 supporte 7 types de routing politiques :

```
1. SIMPLE
   └─ Un record = une valeur (ou plusieurs, retournées aléatoirement)
   └─ Pas de health checks
   └─ Usage: DNS basique

2. WEIGHTED
   └─ Contrôler % trafic vers chaque ressource
   └─ 70% → API A, 30% → API B (canary)
   └─ Avec health checks

3. LATENCY
   └─ Route vers ressource avec latence la plus basse
   └─ API région US-EAST-1 vs EU-WEST-1
   └─ Idéal: utilisateurs globaux

4. FAILOVER
   └─ Primaire → Secondaire si health check échoue
   └─ Active-Passive
   └─ Usage: haute disponibilité

5. GEOLOCATION
   └─ Route basé sur localisation géographique
   └─ EU → CDN Europe, APAC → CDN Singapour
   └─ Respect des régulations données (RGPD, etc)

6. GEOPROXIMITY
   └─ Route basé sur localisation + biais
   └─ Comme geolocation mais plus fin
   └─ Plus complexe, moins courant

7. MULTIVALUE
   └─ Retourne jusqu'à 8 IPs saines
   └─ Pas équivalent à load balancer
   └─ Usage: DNS-level fail-over simple
```

**Pour cette infrastructure : Weighted + Failover**

---

## Types de Records DNS

### Records courants

```dns
A RECORD (IPv4)
  api.domaine.com.  300  IN  A  203.0.113.42
  ↑ Nom            ↑TTL  ↑Class ↑Type ↑IP

AAAA RECORD (IPv6)
  api.domaine.com.  300  IN  AAAA  2001:db8::1

CNAME RECORD (Alias texte)
  mail.domaine.com.  300  IN  CNAME  mail.google.com.
  ⚠️ Ne peut pas être au apex (domaine.com)

ALIAS RECORD (AWS-specific, pas de TTL)
  api.domaine.com.       IN  A  <ALB DNS name>
  ✓ Peut être à l'apex
  ✓ Gratis (pas facturé comme requête Route53)
  ✓ Pointage vers AWS resources

MX RECORD (Mail)
  domaine.com.  300  IN  MX  10 mail.domaine.com.
  └─ 10 = priorité (plus bas = priorité plus haute)

TXT RECORD (Texte, SPF/DKIM)
  domaine.com.  300  IN  TXT  "v=spf1 include:_spf.google.com ~all"

NS RECORD (Nameserver)
  domaine.com.  172800  IN  NS  ns-123.awsdns-45.com.
  └─ Délégation vers nameserver autoritaire

SOA RECORD (Start of Authority)
  domaine.com.  900  IN  SOA  ns-123.awsdns-45.com. admin.domaine.com. ...
  └─ Métadonnées de la zone
```

### Alias Route53 vs CNAME

| Aspect | CNAME | ALIAS |
|--------|-------|-------|
| **Pointage** | Nom DNS → Nom DNS | Nom DNS → Ressource AWS |
| **Apex (root)** | ❌ Interdit | ✅ Autorisé |
| **Facturation** | Comptabilisé | ❌ Gratuit |
| **Latence** | +1 lookup | Optimisé |
| **Exemple** | `www` → `old.com` | `api` → ALB DNS |
| **Ressources** | N'importe où | ALB, CloudFront, S3, etc |

### Health Checks

Route53 peut surveiller la santé de vos ressources :

```
Health Check Types:
├─ HTTP/HTTPS
├─ TCP
├─ CloudWatch Alarm
├─ Calculated (combinaison)
└─ Private (pour ressources privées)

Configuration:
├─ Endpoint: ALB DNS name
├─ Port: 80, 443, etc
├─ Path: /health
├─ Interval: 30s (standard) ou 10s (fast)
├─ Failure threshold: 3 (combien avant échec)
└─ CloudWatch alarm: optionnel
```

---

## Architecture Infrastructure

### Schéma Vue d'ensemble

```
┌─────────────────────────────────────────────────────────┐
│ AWS South-2 (Region)                                    │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  Internet (Users worldwide)                              │
│           ↓ (Route53 DNS)                                │
│  ┌────────────────────────────────────────────┐          │
│  │  DNS Zone: domaine.com (Route53)            │          │
│  │  ├─ api.domaine.com → ALB (Cluster A/B)    │          │
│  │  ├─ admin.domaine.com → Bastion (Nat IP)   │          │
│  │  ├─ internal.domaine.com → VPC Resolver    │          │
│  │  └─ aden.domaine.com → External service    │          │
│  └────────────────────────────────────────────┘          │
│                                                           │
│  ┌─────────────────────────────────────────────────┐    │
│  │  VPC: 10.0.0.0/16                              │    │
│  │                                                  │    │
│  │  ┌────────────────┐      ┌────────────────┐    │    │
│  │  │ Public Subnet  │      │ Public Subnet  │    │    │
│  │  │ 10.0.1.0/24    │      │ 10.0.2.0/24    │    │    │
│  │  │ ┌──────────┐   │      │ ┌──────────┐   │    │    │
│  │  │ │ Bastion  │   │      │ │ Bastion  │   │    │    │
│  │  │ │ 10.0.1.x │   │      │ │ 10.0.2.x │   │    │    │
│  │  │ └──────────┘   │      │ └──────────┘   │    │    │
│  │  │ NAT Gateway    │      │ NAT Gateway    │    │    │
│  │  └────────────────┘      └────────────────┘    │    │
│  │           ↓                      ↓              │    │
│  │  ┌────────────────┐      ┌────────────────┐    │    │
│  │  │ Private Subnet │      │ Private Subnet │    │    │
│  │  │ 10.0.10.0/24   │      │ 10.0.11.0/24   │    │    │
│  │  │ ┌────────────┐ │      │ ┌────────────┐ │    │    │
│  │  │ │ Cluster A  │ │      │ │ Cluster B  │ │    │    │
│  │  │ │ ┌────────┐ │ │      │ │ ┌────────┐ │ │    │    │
│  │  │ │ │ EC2-1  │ │ │      │ │ │ EC2-3  │ │ │    │    │
│  │  │ │ │ EC2-2  │ │ │      │ │ │ EC2-4  │ │ │    │    │
│  │  │ │ └────────┘ │ │      │ │ └────────┘ │ │    │    │
│  │  │ └────────────┘ │      │ └────────────┘ │    │    │
│  │  └────────────────┘      └────────────────┘    │    │
│  │           ↑                      ↑              │    │
│  │  ┌──────────────────────────────────────┐      │    │
│  │  │ Application Load Balancer (ALB)      │      │    │
│  │  │ - Security Group: port 80/443        │      │    │
│  │  │ - Target Groups: Cluster A + B      │      │    │
│  │  │ - DNS: alb-xxxxx.elb.amazonaws.com  │      │    │
│  │  └──────────────────────────────────────┘      │    │
│  │                                                  │    │
│  │  ┌──────────────────────────────────────┐      │    │
│  │  │ VPC Resolver (Private Zone)          │      │    │
│  │  │ - internal.domaine.com → 10.0.x.x    │      │    │
│  │  └──────────────────────────────────────┘      │    │
│  └─────────────────────────────────────────────────┘    │
│                                                           │
└─────────────────────────────────────────────────────────┘

External:
  aden.domaine.com → 203.0.113.99 (Partenaire service)
```

### Flux de trafic DNS

```
Cas 1: Client externe résout api.domaine.com
  User (8.8.8.8)
    ↓ "donne-moi api.domaine.com"
  Route53 (Authoritative pour domaine.com)
    ↓ "Voici l'ALB: alb-xxxxx.elb.amazonaws.com"
  User
    ↓ "Maintenant je me connecte à l'ALB"
  ALB (Route53 Alias points ici)
    ↓ "Je te route vers Cluster A/B"
  EC2 Cluster A ou B
    ↓ "Voici ta réponse"
  User ✓

Cas 2: Client interne résout internal.domaine.com
  EC2 (dans VPC 10.0.0.0/16)
    ↓ "Je veux internal.domaine.com"
  VPC Resolver (Route53 Private Zone)
    ↓ "C'est un réseau interne: 10.0.20.50"
  EC2 ✓ (utilise route privée, pas d'internet)

Cas 3: Client externe résout admin.domaine.com
  User (8.8.8.8)
    ↓ "donne-moi admin.domaine.com"
  Route53
    ↓ "Voici Bastion: 203.0.113.50"
  User
    ↓ "Je me connecte au Bastion via SSH"
  Bastion ✓
```

---

## Configuration Complète

### Records nécessaires

```
ZONE: domaine.com
┌─────────────────────────────────────────────────────┐
│ Apex (domaine.com)                                  │
├─────────────────────────────────────────────────────┤
│ • A record → Alias Route53 vers ALB               │
│   (pour accès root au site, exemple: www)         │
│ • MX records (optionnel, pour email)              │
│ • TXT records (SPF, DKIM, DMARC)                  │
│ • NS records (gérés automatiquement)              │
│ • SOA record (géré automatiquement)               │
└─────────────────────────────────────────────────────┘

api.domaine.com
├─ Type: Alias A
├─ Target: ALB DNS name
├─ Routing Policy: Weighted (A/B testing possible)
├─ Health Check: ALB health endpoint
└─ TTL: 300s (changement rapide possible)

admin.domaine.com
├─ Type: A
├─ Value: Bastion Elastic IP
├─ Routing Policy: Simple (une seule IP)
├─ Health Check: TCP port 22
└─ TTL: 3600s (stable, change rarement)

internal.domaine.com
├─ Type: Private Alias (VPC Resolver)
├─ Target: Service Discovery/ENI IP
├─ VPC: 10.0.0.0/16 only
├─ TTL: N/A (private)
└─ Usage: inter-cluster communication

aden.domaine.com
├─ Type: CNAME ou A
├─ Value: 203.0.113.99 (External partner)
├─ TTL: 300s (peut changer)
└─ Note: CNAME ne fonctionne pas à l'apex
```

### Considérations d'architecture

```
1. HEALTH CHECKS POUR api.domaine.com
   ├─ Endpoint: ALB
   ├─ Path: /health ou /
   ├─ Port: 443 (HTTPS)
   ├─ Interval: 30s
   ├─ Failure threshold: 3
   └─ CloudWatch: Optionnel (alerter si down)

2. FAILOVER PROTECTION
   ├─ Weighted routing (70% A, 30% B)
   ├─ OR Failover routing (Primary/Secondary)
   ├─ Health checks obligatoires
   └─ TTL court (300s) pour basculement rapide

3. SECURITY GROUPS
   ├─ ALB: allow 80, 443 from 0.0.0.0/0
   ├─ Bastion: allow 22 from admin IPs only
   ├─ Clusters: allow 8080 from ALB only
   └─ Ensure no direct internet access pour clusters

4. ZONES PRIVÉES (Private Hosted Zones)
   ├─ Pour internal.domaine.com
   ├─ Visible uniquement depuis VPC 10.0.0.0/16
   ├─ Résolution via Route53 Resolver
   └─ Pas facturé comme requête DNS

5. TTL STRATEGY
   ├─ Endpoints dynamiques (ALB, Bastion): 300s
   ├─ Services stables (internes): 3600s
   ├─ Pendant migration/canary: 60-300s
   └─ Production stable: 3600-86400s
```

### Coûts Route53

| Opération | Coût |
|-----------|------|
| Hosted Zone | $0.50/mois |
| Query | $0.40 par million |
| Health Check | $0.50/mois par check |
| Private Zone | $1.00/mois |
| Alias Query (AWS) | Gratuit |

**Estimation pour cette infra :**
- 1 zone publique + 1 zone privée : $1.50/mois
- 2 health checks (ALB + Bastion) : $1.00/mois
- 10M requêtes/mois : $4.00/mois
- **Total: ~$6.50/mois**

---

## Validation et Tests

### Commandes DNS de base

```bash
# Vérifier l'enregistrement A
dig api.domaine.com

# Vérifier NS records
dig ns domaine.com

# Vérifier tous les records
dig domaine.com ANY

# Interroger nameserver spécifique
dig @ns-123.awsdns-45.com api.domaine.com

# Trace complète (recursive)
dig +trace api.domaine.com

# Short form
dig +short api.domaine.com

# Reverse DNS
dig -x 203.0.113.42
```

### Tester propagation globale

```bash
# Utiliser un outil en ligne
# https://www.whatsmydns.net/

# Via CLI (si disponible)
nslookup api.domaine.com 8.8.8.8
nslookup api.domaine.com 1.1.1.1
nslookup api.domaine.com ns-123.awsdns-45.com
```

### Validation Route53 (AWS CLI)

```bash
# Lister zones
aws route53 list-hosted-zones

# Lister records d'une zone
aws route53 list-resource-record-sets --hosted-zone-id Z123456XXXX

# Vérifier health check
aws route53 get-health-check-status --health-check-id <id>

# Teste DNS resolution
aws route53 test-dns-answer \
  --hosted-zone-id Z123456XXXX \
  --record-name api.domaine.com \
  --record-type A
```

---

## Bonnes pratiques

### Avant production

- [ ] Mettre en place health checks pour toutes ressources critiques
- [ ] Utiliser weighted ou failover routing (jamais simple pour critique)
- [ ] Tester la propagation DNS dans 5+ régions (whatsmydns.net)
- [ ] TTL court (300s) pour endpoints dynamiques
- [ ] Documenter tous les records et leur raison
- [ ] Sécuriser l'accès Route53 avec IAM roles
- [ ] Activer CloudTrail pour auditer changements DNS

### En production

- [ ] Monitoring des health checks (CloudWatch alarms)
- [ ] Alertes si health check fail
- [ ] Logs de toutes requêtes (CloudWatch Logs)
- [ ] Runbook pour basculement manuel si needed
- [ ] Backup de la zone (exportable via CLI)
- [ ] Rotation des NS records semestriellement
- [ ] Planifier migration si besoin de registrar

### Troubleshooting

```
Problème: Nouveau record ne résout pas
Solution:
  1. Vérifier TTL ancien cache (attendre)
  2. Vérifier NS records corrects chez registrar
  3. Tester avec nameserver spécifique
     dig @ns-123.awsdns-45.com api.domaine.com

Problème: Health check échoue mais service OK
Solution:
  1. Vérifier endpoint health exactement
  2. Vérifier security group autorisant health check
  3. Augmenter failure threshold
  4. Vérifier CloudWatch logs

Problème: ALB non accessible via DNS
Solution:
  1. Vérifier ALB se crée correctement (terraform apply)
  2. Vérifier Alias record pointe vers bon ALB DNS name
  3. Vérifier SG ALB autorise port 80/443
  4. Tester ALB directement via son DNS name
```

---

## Checklist Implémentation

- [ ] Créer zone publique domaine.com dans Route53
- [ ] Copier NS records vers registrar (GoDaddy)
- [ ] Créer ALB dans VPC
- [ ] Créer Elastic IP pour Bastion
- [ ] Créer Alias A record api.domaine.com → ALB
- [ ] Créer A record admin.domaine.com → Bastion EIP
- [ ] Créer Private Hosted Zone pour internal.domaine.com
- [ ] Configurer health checks pour ALB (port 443, path /health)
- [ ] Configurer health check pour Bastion (TCP port 22)
- [ ] Tester résolution via dig + CLI
- [ ] Valider propagation globale (whatsmydns.net)
- [ ] Documenter tous les records
- [ ] Configurer CloudWatch alarms
- [ ] Tester failover (arrêter ALB, vérifier basculement)

---

**Dernière mise à jour:** Août 2026  
**Auteur:** Formation DevOps AWS/Terraform  
**Audience:** Débutants - Intermédiaires  
