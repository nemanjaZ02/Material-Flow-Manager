-- =======================================================
--  1. KREIRANJE STRUKTURE TABELA I PRIMARNIH KLJUČEVA
-- =======================================================

CREATE TABLE dobavljac (
    d_id    INTEGER NOT NULL,
    d_tel   VARCHAR(255) NOT NULL,
    d_ime   VARCHAR(255) NOT NULL,
    d_prz   VARCHAR(255) NOT NULL
);
ALTER TABLE dobavljac ADD CONSTRAINT dobavljac_PK PRIMARY KEY (d_id);

CREATE TABLE dobavljac_materijal (
    dobavljac_d_id  INTEGER NOT NULL,
    materijal_m_id  INTEGER NOT NULL,
    dm_kol          INTEGER NOT NULL
);
ALTER TABLE dobavljac_materijal ADD CONSTRAINT dobavljac_materijal_PK PRIMARY KEY (materijal_m_id, dobavljac_d_id);

CREATE TABLE gradiliste (
    g_id                        INTEGER NOT NULL,
    g_adr                       VARCHAR(255) NOT NULL,
    gradjevinska_firma_f_pib    CHAR(9) NOT NULL
);
ALTER TABLE gradiliste ADD CONSTRAINT gradiliste_PK PRIMARY KEY (g_id);

CREATE TABLE gradjevinska_firma (
    f_pib   CHAR(9) NOT NULL,
    f_naz   VARCHAR(255) NOT NULL,
    f_adr   VARCHAR(255) NOT NULL,
    f_eml   VARCHAR(255) NOT NULL
);
ALTER TABLE gradjevinska_firma ADD CONSTRAINT gradjevinska_firma_PK PRIMARY KEY (f_pib);

CREATE TABLE klijent (
    k_id    INTEGER NOT NULL,
    k_ime   VARCHAR(255) NOT NULL,
    k_prz   VARCHAR(255) NOT NULL,
    k_eml   VARCHAR(255) NOT NULL
);
ALTER TABLE klijent ADD CONSTRAINT klijent_PK PRIMARY KEY (k_id);

CREATE TABLE komercijala (
    z_jmbg  CHAR(13) NOT NULL,
    k_brdob INTEGER
);
ALTER TABLE komercijala ADD CONSTRAINT komercijala_PK PRIMARY KEY (z_jmbg);

CREATE TABLE lista (
    lm_id               INTEGER NOT NULL,
    projektant_z_jmbg   CHAR(13) NOT NULL
);
ALTER TABLE lista ADD CONSTRAINT lista_PK PRIMARY KEY (lm_id);

CREATE TABLE majstor (
    z_jmbg  CHAR(13) NOT NULL,
    m_spec  VARCHAR(255)
);
ALTER TABLE majstor ADD CONSTRAINT majstor_PK PRIMARY KEY (z_jmbg);

CREATE TABLE materijal (
    m_id    INTEGER NOT NULL,
    m_tip   VARCHAR(255) NOT NULL
);
ALTER TABLE materijal ADD CONSTRAINT materijal_PK PRIMARY KEY (m_id);

CREATE TABLE plan_izgradnje (
    pi_id               INTEGER NOT NULL,
    pi_rok              TIMESTAMP NOT NULL,
    projektant_z_jmbg   CHAR(13) NOT NULL
);
ALTER TABLE plan_izgradnje ADD CONSTRAINT plan_izgradnje_PK PRIMARY KEY (pi_id);

CREATE TABLE projektant (
    z_jmbg  CHAR(13) NOT NULL,
    p_spec  VARCHAR(255),
    p_brlm  INTEGER,
    p_brpi  INTEGER
);
ALTER TABLE projektant ADD CONSTRAINT projektant_PK PRIMARY KEY (z_jmbg);

CREATE TABLE skladisni_materijal (
    skladiste_s_id  INTEGER NOT NULL,
    materijal_m_id  INTEGER NOT NULL,
    sm_kol          INTEGER NOT NULL
);
ALTER TABLE skladisni_materijal ADD CONSTRAINT skladisni_materijal_PK PRIMARY KEY (skladiste_s_id, materijal_m_id);

CREATE TABLE skladiste (
    s_id                        INTEGER NOT NULL,
    s_kap                       INTEGER NOT NULL,
    gradjevinska_firma_f_pib    CHAR(9) NOT NULL
);
ALTER TABLE skladiste ADD CONSTRAINT skladiste_PK PRIMARY KEY (s_id);

CREATE TABLE stavka_liste (
    lista_lm_id     INTEGER NOT NULL,
    materijal_m_id  INTEGER NOT NULL,
    sl_kol          INTEGER NOT NULL
);
ALTER TABLE stavka_liste ADD CONSTRAINT stavka_liste_PK PRIMARY KEY (lista_lm_id, materijal_m_id);

CREATE TABLE transport (
    ps_id                       INTEGER NOT NULL,
    ps_zau                      BOOLEAN DEFAULT FALSE,
    ps_kap                      INTEGER,
    gradjevinska_firma_f_pib    CHAR(9) NOT NULL,
    majstor_z_jmbg              CHAR(13) -- Strani ključ ka majstoru, može biti NULL
);
ALTER TABLE transport ADD CONSTRAINT transport_PK PRIMARY KEY (ps_id);
-- UNIQUE da 1 majstor može voziti samo 1 vozilo
ALTER TABLE transport ADD CONSTRAINT uq_transport_majstor UNIQUE (majstor_z_jmbg);

CREATE TABLE transport_gradiliste (
    transport_ps_id INTEGER NOT NULL,
    gradiliste_g_id INTEGER NOT NULL
);
-- Primarni ključ za spojnu tabelu
ALTER TABLE transport_gradiliste ADD CONSTRAINT transport_gradiliste_PK PRIMARY KEY (transport_ps_id, gradiliste_g_id);


CREATE TABLE transport_materijal (
    tm_kol          INTEGER,
    materijal_m_id  INTEGER NOT NULL,
    transport_ps_id INTEGER NOT NULL
);
ALTER TABLE transport_materijal ADD CONSTRAINT transport_materijal_PK PRIMARY KEY (transport_ps_id, materijal_m_id);

CREATE TABLE ugovor (
    ug_sklop        CHAR(1) NOT NULL,
    dobavljac_d_id  INTEGER NOT NULL,
    skladiste_s_id  INTEGER NOT NULL,
    zahtev_z_id     INTEGER NOT NULL
);
CREATE UNIQUE INDEX ugovor_zahtev_id_idx ON ugovor (zahtev_z_id);
ALTER TABLE ugovor ADD CONSTRAINT ugovor_PK PRIMARY KEY (dobavljac_d_id, skladiste_s_id, zahtev_z_id);

CREATE TABLE zahtev (
    z_id                INTEGER NOT NULL,
    z_status            VARCHAR(20),
    z_dat               TIMESTAMP,
    z_opis              TEXT,
    klijent_k_id        INTEGER NOT NULL,
    komercijala_z_jmbg  CHAR(13) NOT NULL
);
ALTER TABLE zahtev ADD CONSTRAINT zahtev_PK PRIMARY KEY (z_id);

CREATE TABLE zaposleni (
    z_jmbg                      CHAR(13) NOT NULL,
    z_ulg                       VARCHAR(13) NOT NULL,
    z_ime                       VARCHAR(255) NOT NULL,
    z_prz                       VARCHAR(255) NOT NULL,
    z_plt                       NUMERIC NOT NULL,
    gradjevinska_firma_f_pib    CHAR(9) NOT NULL,
    zaposleni_z_jmbg            CHAR(13),
    CONSTRAINT CH_INH_zaposleni CHECK (z_ulg IN ('komercijala', 'majstor', 'projektant', 'zaposleni'))
);
ALTER TABLE zaposleni ADD CONSTRAINT zaposleni_PK PRIMARY KEY (z_jmbg);


-- =======================================================
--  2. DODAVANJE SPOLJNIH KLJUČEVA (FOREIGN KEYS)
-- =======================================================

ALTER TABLE dobavljac_materijal ADD CONSTRAINT fk_dm_dobavljac FOREIGN KEY (dobavljac_d_id) REFERENCES dobavljac (d_id);
ALTER TABLE dobavljac_materijal ADD CONSTRAINT fk_dm_materijal FOREIGN KEY (materijal_m_id) REFERENCES materijal (m_id);
ALTER TABLE gradiliste ADD CONSTRAINT fk_gradiliste_firma FOREIGN KEY (gradjevinska_firma_f_pib) REFERENCES gradjevinska_firma (f_pib);
ALTER TABLE komercijala ADD CONSTRAINT fk_komercijala_zaposleni FOREIGN KEY (z_jmbg) REFERENCES zaposleni (z_jmbg);
ALTER TABLE lista ADD CONSTRAINT fk_lista_projektant FOREIGN KEY (projektant_z_jmbg) REFERENCES projektant (z_jmbg);
ALTER TABLE majstor ADD CONSTRAINT fk_majstor_zaposleni FOREIGN KEY (z_jmbg) REFERENCES zaposleni (z_jmbg);
ALTER TABLE plan_izgradnje ADD CONSTRAINT fk_plan_projektant FOREIGN KEY (projektant_z_jmbg) REFERENCES projektant (z_jmbg);
ALTER TABLE projektant ADD CONSTRAINT fk_projektant_zaposleni FOREIGN KEY (z_jmbg) REFERENCES zaposleni (z_jmbg);
ALTER TABLE skladisni_materijal ADD CONSTRAINT fk_sm_materijal FOREIGN KEY (materijal_m_id) REFERENCES materijal (m_id);
ALTER TABLE skladisni_materijal ADD CONSTRAINT fk_sm_skladiste FOREIGN KEY (skladiste_s_id) REFERENCES skladiste (s_id);
ALTER TABLE skladiste ADD CONSTRAINT fk_skladiste_firma FOREIGN KEY (gradjevinska_firma_f_pib) REFERENCES gradjevinska_firma (f_pib);
ALTER TABLE stavka_liste ADD CONSTRAINT fk_sl_lista FOREIGN KEY (lista_lm_id) REFERENCES lista (lm_id);
ALTER TABLE stavka_liste ADD CONSTRAINT fk_sl_materijal FOREIGN KEY (materijal_m_id) REFERENCES materijal (m_id);
ALTER TABLE transport_gradiliste ADD CONSTRAINT fk_tg_gradiliste FOREIGN KEY (gradiliste_g_id) REFERENCES gradiliste (g_id);
ALTER TABLE transport_gradiliste ADD CONSTRAINT fk_tg_transport FOREIGN KEY (transport_ps_id) REFERENCES transport (ps_id);
ALTER TABLE transport ADD CONSTRAINT fk_transport_firma FOREIGN KEY (gradjevinska_firma_f_pib) REFERENCES gradjevinska_firma (f_pib);
ALTER TABLE transport ADD CONSTRAINT fk_transport_majstor FOREIGN KEY (majstor_z_jmbg) REFERENCES majstor(z_jmbg) ON DELETE SET NULL; -- Ključna veza
ALTER TABLE transport_materijal ADD CONSTRAINT fk_tm_materijal FOREIGN KEY (materijal_m_id) REFERENCES materijal (m_id);
ALTER TABLE transport_materijal ADD CONSTRAINT fk_tm_transport FOREIGN KEY (transport_ps_id) REFERENCES transport (ps_id);
ALTER TABLE ugovor ADD CONSTRAINT fk_ugovor_dobavljac FOREIGN KEY (dobavljac_d_id) REFERENCES dobavljac (d_id);
ALTER TABLE ugovor ADD CONSTRAINT fk_ugovor_skladiste FOREIGN KEY (skladiste_s_id) REFERENCES skladiste (s_id);
ALTER TABLE ugovor ADD CONSTRAINT fk_ugovor_zahtev FOREIGN KEY (zahtev_z_id) REFERENCES zahtev (z_id);
ALTER TABLE zahtev ADD CONSTRAINT fk_zahtev_klijent FOREIGN KEY (klijent_k_id) REFERENCES klijent (k_id);
ALTER TABLE zahtev ADD CONSTRAINT fk_zahtev_komercijala FOREIGN KEY (komercijala_z_jmbg) REFERENCES komercijala (z_jmbg);
ALTER TABLE zaposleni ADD CONSTRAINT fk_zaposleni_firma FOREIGN KEY (gradjevinska_firma_f_pib) REFERENCES gradjevinska_firma (f_pib);
ALTER TABLE zaposleni ADD CONSTRAINT fk_zaposleni_zaposleni FOREIGN KEY (zaposleni_z_jmbg) REFERENCES zaposleni (z_jmbg);


-- =======================================================
--  3. KREIRANJE TRIGERA
-- =======================================================

-- Triger funkcija za proveru uloge zaposlenog (Arc)
CREATE OR REPLACE FUNCTION check_zaposleni_role()
RETURNS TRIGGER AS $$
DECLARE
    v_role VARCHAR;
BEGIN
    SELECT z_ulg INTO v_role FROM zaposleni WHERE z_jmbg = NEW.z_jmbg;
    IF NOT FOUND OR v_role IS NULL OR v_role <> TG_ARGV[0] THEN
        RAISE EXCEPTION 'FK constraint violation: Zaposleni % ne postoji ili nema ulogu %', NEW.z_jmbg, TG_ARGV[0];
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_projektant_role BEFORE INSERT OR UPDATE ON projektant FOR EACH ROW EXECUTE FUNCTION check_zaposleni_role('projektant');
CREATE TRIGGER trg_check_komercijala_role BEFORE INSERT OR UPDATE ON komercijala FOR EACH ROW EXECUTE FUNCTION check_zaposleni_role('komercijala');
CREATE TRIGGER trg_check_majstor_role BEFORE INSERT OR UPDATE ON majstor FOR EACH ROW EXECUTE FUNCTION check_zaposleni_role('majstor');


-- Triger funkcija za automatsko ažuriranje statusa 'ps_zau' u tabeli transport
CREATE OR REPLACE FUNCTION update_ps_zau_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.majstor_z_jmbg IS NOT NULL THEN
        NEW.ps_zau := true;
    ELSE
        NEW.ps_zau := false;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_transport_update_ps_zau BEFORE INSERT OR UPDATE ON transport FOR EACH ROW EXECUTE FUNCTION update_ps_zau_status();