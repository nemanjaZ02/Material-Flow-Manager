const { query } = require('../db/query');

const simpleDAO = {
		/* Prosecna plata po specijalizaciji majstora.
		Niz objekata sa { m_spec, prosecna_plata } */
    getAverageSalaryBySpecialization: async () => {
        const sql = `
            SELECT 
                m.m_spec,
                ROUND(AVG(z.z_plt), 2) AS prosecna_plata
            FROM majstor m
            JOIN zaposleni z ON m.z_jmbg = z.z_jmbg
            GROUP BY m.m_spec
            ORDER BY prosecna_plata DESC;
        `;
        const { rows } = await query(sql);
        return rows;
    },

		/* Broj zaposlenih za svaku gradjevinsku firmu.
    Niz objekata sa { f_naz, broj_zaposlenih } */
    getEmployeeCountByCompany: async () => {
        const sql = `
            SELECT
                gf.f_naz,
                COUNT(z.z_jmbg) AS broj_zaposlenih
            FROM gradjevinska_firma gf
            LEFT JOIN zaposleni z ON gf.f_pib = z.gradjevinska_firma_f_pib
            GROUP BY gf.f_naz
            ORDER BY broj_zaposlenih DESC;
        `;
        const { rows } = await query(sql);
        return rows;
    }
};

module.exports = simpleDAO;
