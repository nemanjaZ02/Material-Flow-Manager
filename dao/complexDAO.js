const { query } = require('../db/query');

const complexDAO = {
    /* Aktivna vozila sa podacima o vozacima (majstorima) cija je plata > 60000.
 		Vraca niz objekata sa { ps_id, firma, vozac, specijalizacija, plata } */
    getActiveVehiclesWithDrivers: async () => {
        const sql = `
            SELECT
                t.ps_id,
                gf.f_naz AS firma,
                z.z_ime || ' ' || z.z_prz AS vozac,
                m.m_spec AS specijalizacija,
                z.z_plt AS plata
            FROM transport t
            JOIN gradjevinska_firma gf ON t.gradjevinska_firma_f_pib = gf.f_pib
            LEFT JOIN majstor m ON t.majstor_z_jmbg = m.z_jmbg
            LEFT JOIN zaposleni z ON m.z_jmbg = z.z_jmbg
            WHERE z.z_plt > 60000
            ORDER BY z.z_plt DESC;
        `;
        const { rows } = await query(sql);
        return rows;
    },

    /* Statistika po firmama koje imaju vise od 2 majstora.
		Vraca niz objekata sa: { f_naz, zaposlenih, majstora, prosecni_kapacitet_vozila } */
    getCompanyStatistics: async () => {
        const sql = `
            SELECT
                gf.f_naz,
                COUNT(DISTINCT z.z_jmbg) AS zaposlenih,
                COUNT(DISTINCT m.z_jmbg) AS majstora,
                ROUND(AVG(t.ps_kap)) AS pros_kapacitet_vozila
            FROM gradjevinska_firma gf
            LEFT JOIN zaposleni z ON gf.f_pib = z.gradjevinska_firma_f_pib
            LEFT JOIN majstor m ON z.z_jmbg = m.z_jmbg
            LEFT JOIN transport t ON gf.f_pib = t.gradjevinska_firma_f_pib
            GROUP BY gf.f_naz
            HAVING COUNT(DISTINCT m.z_jmbg) > 2
            ORDER BY zaposlenih DESC;
        `;
        const { rows } = await query(sql);
        return rows;
    }
};

module.exports = complexDAO;