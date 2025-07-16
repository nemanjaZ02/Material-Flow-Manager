const simpleDAO = require('../dao/simpleDAO');
const simpleDTO = require('../dto/simpleDTO');

const simpleService = {
    /**
     * Priprema izvestaj o prosecnim platama.
     */
    getAverageSalaryReport: async () => {
        const salaryData = await simpleDAO.getAverageSalaryBySpecialization();
        return simpleDTO.createSalaryReportDTO(salaryData);
    },

    /**
     * Priprema izvestaj o broju zaposlenih po firmama.
     */
    getEmployeeCountReport: async () => {
        const employeeCountData = await simpleDAO.getEmployeeCountByCompany();
        return simpleDTO.createEmployeeCountDTO(employeeCountData);
    }
};

module.exports = simpleService;