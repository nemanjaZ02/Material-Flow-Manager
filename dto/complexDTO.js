const complexDTO = {
    createActiveVehiclesDTO: (dbRows) => {
        if (!dbRows || dbRows.length === 0) return [];

        return dbRows.map(row => ({
            "ID Vozila": row.ps_id,
            "Firma": row.firma,
            "Vozac": row.vozac,
            "Specijalizacija": row.specijalizacija,
            "Plata vozaca": `${row.plata} RSD`
        }));
    },

    createCompanyStatsDTO: (dbRows) => {
        if (!dbRows || dbRows.length === 0) return [];

        return dbRows.map(row => ({
            "Naziv Firme": row.f_naz,
            "Ukupno Zaposlenih": parseInt(row.zaposlenih, 10),
            "Broj Majstora": parseInt(row.majstora, 10),
            "Pros. Kapacitet Vozila (kg)": row.pros_kapacitet_vozila ? parseInt(row.pros_kapacitet_vozila, 10) : 'N/A'
        }));
    }
};

module.exports = complexDTO;