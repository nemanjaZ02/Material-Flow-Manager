const complexDAO = require('../dao/complexDAO');
const complexDTO = require('../dto/complexDTO');

const complexService = {
    getActiveVehiclesReport: async () => {
        const vehicleData = await complexDAO.getActiveVehiclesWithDrivers();
        return complexDTO.createActiveVehiclesDTO(vehicleData);
    },

    getCompanyStatisticsReport: async () => {
        const companyData = await complexDAO.getCompanyStatistics();
        return complexDTO.createCompanyStatsDTO(companyData);
    }
};

module.exports = complexService;