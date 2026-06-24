DROP TABLE IF EXISTS transilien;

CREATE TABLE transilien (
    date                    VARCHAR(7),
    service                 VARCHAR(255),
    ligne                   VARCHAR(50),
    nom_de_la_ligne         VARCHAR(255),
    taux_de_ponctualite     FLOAT,
    voyageurs_en_retard     FLOAT,
    CONSTRAINT pk_transilien PRIMARY KEY (date, ligne)
);

DROP TABLE IF EXISTS intercites;

CREATE TABLE intercites (
    date                    VARCHAR(7),
    depart                  VARCHAR(255),
    arrivee                 VARCHAR(255),
    nb_trains_programmes    INTEGER,
    nb_trains_circules      INTEGER,
    nb_trains_annules       INTEGER,
    nb_trains_retard        INTEGER,
    taux_regularite         FLOAT,
    trains_heure_par_retard FLOAT,
    CONSTRAINT pk_intercites PRIMARY KEY (date, depart, arrivee)
);