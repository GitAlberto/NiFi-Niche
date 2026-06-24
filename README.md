# NiFi-Niche 🚂

Pipeline de données end-to-end pour l'ingestion et l'analyse de la régularité des trains SNCF (Transilien & Intercités) — stack 100% dockerisée avec Apache NiFi 2.6, NiFi Registry, PostgreSQL et Power BI.

---

## Architecture

```
data.sncf.com (API REST)
        ↓
   Apache NiFi 2.6
   ├── InvokeHTTP       → téléchargement du CSV via API
   ├── UpdateAttribute  → renommage dynamique du fichier (date du jour)
   ├── PutFile          → sauvegarde locale dans nifishare/output/
   ├── QueryRecord      → normalisation des colonnes (snake_case)
   └── PutDatabaseRecord → ingestion UPSERT dans PostgreSQL
        ↓
   PostgreSQL 16
   ├── transilien  (2 035 lignes)
   └── intercites  (5 915 lignes)
        ↓
   Power BI Desktop
   └── Dashboard comparatif Transilien vs Intercités
```

---

## Stack technique

| Outil | Version | Rôle |
|---|---|---|
| Apache NiFi | 2.6.0 | Orchestration des pipelines de données |
| NiFi Registry | 1.27.0 | Versioning des pipelines |
| PostgreSQL | 16 | Stockage des données |
| Docker | - | Conteneurisation de la stack |
| Power BI Desktop | - | Visualisation et analyse |

---

## Structure du projet

```
NiFi-Local/
├── docker-compose.yml          # Stack Docker complète
├── .env                        # Credentials (non versionné)
├── .gitignore
├── nifishare/
│   ├── drivers/
│   │   └── postgresql-42.7.3.jar   # Driver JDBC PostgreSQL
│   └── output/                     # Fichiers CSV téléchargés
├── registry/
│   ├── database/               # Base de données NiFi Registry
│   └── flow_storage/           # Pipelines versionnés
└── postgres/
    └── create_tables.sql       # Scripts de création des tables
```

---

## Pipelines NiFi

### Pipeline 03 — SNCF Transilien
- **Source** : `data.sncf.com` — Régularité mensuelle Transilien
- **Destination** : table `transilien` dans PostgreSQL
- **Parameter Context** : `SNCF_Transilien`
- **Données** : 2 035 enregistrements depuis janvier 2013
- **Colonnes** : `date`, `service`, `ligne`, `nom_de_la_ligne`, `taux_de_ponctualite`, `voyageurs_en_retard`
- **Clé primaire** : `(date, ligne)`

### Pipeline 04 — SNCF Intercités
- **Source** : `data.sncf.com` — Régularité mensuelle Intercités
- **Destination** : table `intercites` dans PostgreSQL
- **Parameter Context** : `SNCF_Intercites`
- **Données** : 5 915 enregistrements depuis janvier 2014
- **Colonnes** : `date`, `depart`, `arrivee`, `nb_trains_programmes`, `nb_trains_circules`, `nb_trains_annules`, `nb_trains_retard`, `taux_regularite`, `trains_heure_par_retard`
- **Clé primaire** : `(date, depart, arrivee)`

---

## Concepts NiFi maîtrisés

- **FlowFile** : unité de données transportée dans le pipeline (Attributes + Content)
- **Processor** : brique fonctionnelle (InvokeHTTP, QueryRecord, PutDatabaseRecord...)
- **Controller Service** : service partagé (CSVReader, DBCPConnectionPool...)
- **Parameter Context** : variables dynamiques injectées dans le pipeline (`#{url}`, `#{table}`, `#{filename}`)
- **Back Pressure** : mécanisme de contrôle de flux entre processors
- **Expression Language** : `${now():format('yyyy-MM-dd')}` pour les valeurs dynamiques
- **Data Provenance** : traçabilité complète de chaque FlowFile
- **Registry** : versioning des pipelines (équivalent Git pour NiFi)
- **UPSERT** : insertion idempotente — le pipeline est relançable sans créer de doublons

---

## Démarrage rapide

### Prérequis
- Docker Desktop installé
- Power BI Desktop installé

### Lancer la stack

```bash
# Cloner le projet
git clone https://github.com/GitAlberto/NiFi-Niche.git
cd NiFi-Niche

# Créer le fichier .env
cp .env.example .env
# Remplir les credentials dans .env

# Télécharger le driver JDBC PostgreSQL
curl -o nifishare/drivers/postgresql-42.7.3.jar \
  https://jdbc.postgresql.org/download/postgresql-42.7.3.jar

# Lancer la stack
docker-compose up -d
```

### Accès aux interfaces

| Interface | URL | Credentials |
|---|---|---|
| NiFi | https://localhost:8443/nifi | admin / (voir .env) |
| NiFi Registry | http://localhost:18080/nifi-registry | - |
| PostgreSQL | localhost:5436 | alberto / (voir .env) |

### Créer les tables PostgreSQL

```bash
# Ouvrir pgAdmin4 et exécuter :
postgres/create_tables.sql
```

---

## Points d'attention

- Le driver JDBC PostgreSQL doit être dans `nifishare/drivers/` avant de démarrer NiFi
- Le séparateur CSV du dataset SNCF est `;` — bien configurer le `CSVReader`
- `QueryRecord` utilise **Apache Calcite SQL** (pas PostgreSQL) — les mots réservés (`date`) doivent être entre guillemets doubles
- Les alias dans `QueryRecord` doivent aussi être entre guillemets doubles : `"Date" as "date"`
- `Database Name` dans `PutDatabaseRecord` doit être **vide** (déjà spécifié dans l'URL JDBC)

---

## Auteur

**Alberto Ackhilas BONGUELE**  
Data Engineer — EFREI Paris (Mastère Data Engineering & IA, sept. 2026)  
Portfolio : [alberto-bonguele.vercel.app](https://alberto-bonguele.vercel.app)  
GitHub : [GitAlberto](https://github.com/GitAlberto)
