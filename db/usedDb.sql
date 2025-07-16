CREATE TABLE gradjevinska_firma (
    f_pib   CHAR(9) NOT NULL,
    f_naz   VARCHAR(255) NOT NULL,
    f_adr   VARCHAR(255) NOT NULL,
    f_eml   VARCHAR(255) NOT NULL
);
ALTER TABLE gradjevinska_firma ADD CONSTRAINT gradjevinska_firma_PK PRIMARY KEY (f_pib);

CREATE TABLE zaposleni (
    z_jmbg                      CHAR(13) NOT NULL,
    z_ulg                       VARCHAR(13) NOT NULL,
    z_ime                       VARCHAR(255) NOT NULL,
    z_prz                       VARCHAR(255) NOT NULL,
    z_plt                       NUMERIC NOT NULL,
    gradjevinska_firma_f_pib    CHAR(9) NOT NULL,
    nadredjeni_z_jmbg             CHAR(13),
    CONSTRAINT CH_INH_zaposleni CHECK (z_ulg IN ('komercijala', 'majstor', 'projektant', 'zaposleni'))
);
ALTER TABLE zaposleni ADD CONSTRAINT zaposleni_PK PRIMARY KEY (z_jmbg);

CREATE TABLE majstor (
    z_jmbg  CHAR(13) NOT NULL,
    m_spec  VARCHAR(255)
);
ALTER TABLE majstor ADD CONSTRAINT majstor_PK PRIMARY KEY (z_jmbg);

CREATE TABLE projektant (
    z_jmbg  CHAR(13) NOT NULL,
    p_spec  VARCHAR(255),
    p_brlm  INTEGER,
    p_brpi  INTEGER
);
ALTER TABLE projektant ADD CONSTRAINT projektant_PK PRIMARY KEY (z_jmbg);

CREATE TABLE transport (
    ps_id                       INTEGER NOT NULL,
    ps_zau                      BOOLEAN DEFAULT FALSE,
    ps_kap                      INTEGER,
    gradjevinska_firma_f_pib    CHAR(9) NOT NULL,
    majstor_z_jmbg              CHAR(13)
);
ALTER TABLE transport ADD CONSTRAINT transport_PK PRIMARY KEY (ps_id);
ALTER TABLE transport ADD CONSTRAINT uq_transport_majstor UNIQUE (majstor_z_jmbg);

CREATE TABLE gradiliste (
    g_id                        INTEGER NOT NULL,
    g_adr                       VARCHAR(255) NOT NULL,
    gradjevinska_firma_f_pib    CHAR(9) NOT NULL
);
ALTER TABLE gradiliste ADD CONSTRAINT gradiliste_PK PRIMARY KEY (g_id);
ALTER TABLE zaposleni ADD CONSTRAINT fk_zaposleni_firma FOREIGN KEY (gradjevinska_firma_f_pib) REFERENCES gradjevinska_firma (f_pib);
ALTER TABLE zaposleni ADD CONSTRAINT fk_zaposleni_zaposleni FOREIGN KEY (nadredjeni_z_jmbg) REFERENCES zaposleni (z_jmbg);
ALTER TABLE majstor ADD CONSTRAINT fk_majstor_zaposleni FOREIGN KEY (z_jmbg) REFERENCES zaposleni (z_jmbg);
ALTER TABLE projektant ADD CONSTRAINT fk_projektant_zaposleni FOREIGN KEY (z_jmbg) REFERENCES zaposleni (z_jmbg);
ALTER TABLE transport ADD CONSTRAINT fk_transport_firma FOREIGN KEY (gradjevinska_firma_f_pib) REFERENCES gradjevinska_firma (f_pib);
ALTER TABLE transport ADD CONSTRAINT fk_transport_majstor FOREIGN KEY (majstor_z_jmbg) REFERENCES majstor(z_jmbg) ON DELETE SET NULL;
ALTER TABLE gradiliste ADD CONSTRAINT fk_gradiliste_firma FOREIGN KEY (gradjevinska_firma_f_pib) REFERENCES gradjevinska_firma (f_pib);

CREATE OR REPLACE FUNCTION check_zaposleni_role()
RETURNS TRIGGER AS $$
DECLARE
    v_role VARCHAR;
BEGIN
    IF TG_ARGV[0] IN ('majstor', 'projektant') THEN
        SELECT z_ulg INTO v_role FROM zaposleni WHERE z_jmbg = NEW.z_jmbg;
        IF NOT FOUND OR v_role IS NULL OR v_role <> TG_ARGV[0] THEN
            RAISE EXCEPTION 'FK constraint violation: Zaposleni % ne postoji ili nema ulogu %', NEW.z_jmbg, TG_ARGV[0];
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_majstor_role BEFORE INSERT OR UPDATE ON majstor FOR EACH ROW EXECUTE FUNCTION check_zaposleni_role('majstor');
CREATE TRIGGER trg_check_projektant_role BEFORE INSERT OR UPDATE ON projektant FOR EACH ROW EXECUTE FUNCTION check_zaposleni_role('projektant');

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