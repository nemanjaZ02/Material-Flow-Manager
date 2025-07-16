const { pool } = require('../db/query');
const transactionDAO = require('../dao/transactionDAO');
const transactionDTO = require('../dto/transactionDTO');

const transactionService = {
    hireWorkerAndAssignVehicle: async (jmbg, ime, prezime, plata, firmaPib, specijalizacija) => {
        const workerData = transactionDTO.createNewWorkerData(
            jmbg, ime, prezime, plata, firmaPib, specijalizacija
        );

        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            const availableVehicle = await transactionDAO.findFirstAvailableVehicle();
            if (!availableVehicle) {
                throw new Error('Nema slobodnih vozila za dodelu.');
            }
            const vehicleId = availableVehicle.ps_id;

            await transactionDAO.insertZaposleni(workerData.zaposleniData, client);
            await transactionDAO.insertMajstor(workerData.majstorData, client);
            await transactionDAO.assignVehicleToWorker(vehicleId, workerData.zaposleniData.jmbg, client);

            await client.query('COMMIT');

            const result = { 
                success: true, 
                vehicleId: vehicleId,
                zaposleniIme: workerData.zaposleniData.ime
            };
            return transactionDTO.createSuccessMessage(result);

        } catch (error) {
            await client.query('ROLLBACK');
            console.error('Greska u transakciji, izvrsen je ROLLBACK.');
            throw new Error(error.message); 
        } finally {
            client.release();
        }
    }
};

module.exports = transactionService;