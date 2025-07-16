const simpleDTO = {
    createSalaryReportDTO: (dbRows) => {
        if (!dbRows || dbRows.length === 0) return [];
        
        return dbRows.map(row => ({
            "Specijalizacija": row.m_spec,
            "Prosecna Plata": `${row.prosecna_plata} RSD`
        }));
    },

    createEmployeeCountDTO: (dbRows) => {
        if (!dbRows || dbRows.length === 0) return [];

        return dbRows.map(row => ({
            "Naziv Firme": row.f_naz,
            "Broj Zaposlenih": parseInt(row.broj_zaposlenih, 10)
        }));
    }
};

module.exports = simpleDTO;