DELETE FROM gradiliste;
DELETE FROM transport;
DELETE FROM projektant;
DELETE FROM majstor;
DELETE FROM zaposleni;
DELETE FROM gradjevinska_firma;

INSERT INTO gradjevinska_firma (f_pib, f_naz, f_adr, f_eml) VALUES
('111222333', 'Zidar d.o.o.', 'Glavna 1, Beograd', 'kontakt@zidar.rs'),
('444555666', 'Beton-Staza a.d.', 'Industrijska 5, Novi Sad', 'office@betonstaza.rs');

INSERT INTO zaposleni (z_jmbg, z_ulg, z_ime, z_prz, z_plt, gradjevinska_firma_f_pib) VALUES
('0101980111111', 'majstor', 'Petar', 'Petrovic', 75000, '111222333'),
('0202985222222', 'majstor', 'Marko', 'Markovic', 82000, '111222333'),
('0303990333333', 'majstor', 'Jovan', 'Jovanovic', 58000, '111222333'),
('0404988444444', 'projektant', 'Ana', 'Anic', 110000, '111222333'),
('1101981111111', 'majstor', 'Nikola', 'Nikolic', 95000, '444555666'),
('1202986222222', 'majstor', 'Luka', 'Lukic', 65000, '444555666'),
('1303989333333', 'projektant', 'Jelena', 'Jelic', 140000, '444555666');

INSERT INTO majstor (z_jmbg, m_spec) VALUES
('0101980111111', 'Keramicar'),
('0202985222222', 'Zidar'),
('0303990333333', 'Zidar'),
('1101981111111', 'Armirac'),
('1202986222222', 'Keramicar');

INSERT INTO projektant (z_jmbg, p_spec, p_brlm, p_brpi) VALUES
('0404988444444', 'Visokogradnja', 15, 4),
('1303989333333', 'Visokogradnja', 35, 12);

INSERT INTO transport (ps_id, ps_kap, gradjevinska_firma_f_pib) VALUES
(101, 5000, '111222333'),
(102, 1000, '111222333'),
(201, 10000, '444555666'),
(202, 8000, '444555666');

-- Stavljanje nadredjenog
UPDATE zaposleni SET nadredjeni_z_jmbg = '1303989333333' WHERE z_jmbg = '0404988444444';

-- Stavljanje majstora u transport
UPDATE transport SET majstor_z_jmbg = '0202985222222' WHERE ps_id = 101;
UPDATE transport SET majstor_z_jmbg = '0303990333333' WHERE ps_id = 102;
UPDATE transport SET majstor_z_jmbg = '1101981111111' WHERE ps_id = 201;

INSERT INTO gradiliste (g_id, g_adr, gradjevinska_firma_f_pib) VALUES
(1, 'Novi Beograd, Blok 45', '111222333'),
(3, 'Autoput E-75, deonica BG-NS', '444555666');