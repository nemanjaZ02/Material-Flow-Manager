const transactionDTO = {
    createNewWorkerData: (jmbg, ime, prezime, plata, firmaPib, specijalizacija) => {
        return {
            zaposleniData: { jmbg, ime, prezime, plata, firmaPib },
            majstorData: { jmbg, specijalizacija }
        };
    },

    createSuccessMessage: (result) => {
        if (result.success) {
            return `Uspesno zaposlen majstor ${result.zaposleniIme} i dodeljeno mu je vozilo sa ID: ${result.vehicleId}.`;
        }
        return `Transakcija nije uspela.`;
    }
};

module.exports = transactionDTO;