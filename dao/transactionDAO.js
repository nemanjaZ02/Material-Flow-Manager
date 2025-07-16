const { query } = require('../db/query');

const transactionDAO = {
    /* Pronalazi ID prvog slobodnog vozila.
		Vraca { ps_id } ili null ako nema slobodnih.*/
    findFirstAvailableVehicle: async () => {
        const sql = `SELECT ps_id FROM transport WHERE majstor_z_jmbg IS NULL LIMIT 1;`;
        const { rows } = await query(sql);
        return rows[0] || null;
    },

    /* Unosi novog zaposlenog u tabelu 'zaposleni'. */
    insertZaposleni: async (zaposleniData, client) => {
        const sql = `
            INSERT INTO zaposleni (z_jmbg, z_ulg, z_ime, z_prz, z_plt, gradjevinska_firma_f_pib)
            VALUES ($1, 'majstor', $2, $3, $4, $5);
        `;
        await client.query(sql, [
            zaposleniData.jmbg,
            zaposleniData.ime,
            zaposleniData.prezime,
            zaposleniData.plata,
            zaposleniData.firmaPib
        ]);
    },

    /* Unosi specijalizaciju za novog majstora. */
    insertMajstor: async (majstorData, client) => {
        const sql = `INSERT INTO majstor (z_jmbg, m_spec) VALUES ($1, $2);`;
        await client.query(sql, [majstorData.jmbg, majstorData.specijalizacija]);
    },

    /* Dodeljuje vozilo majstoru (update na tabeli transport). */
    assignVehicleToWorker: async (vehicleId, masterJmbg, client) => {
        const sql = `UPDATE transport SET majstor_z_jmbg = $1 WHERE ps_id = $2;`;
        await client.query(sql, [masterJmbg, vehicleId]);
    }
};

module.exports = transactionDAO;