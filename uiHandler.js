const inquirerPromise = import('inquirer');
const simpleService = require('./services/simpleService');
const complexService = require('./services/complexService');
const transactionService = require('./services/transactionService');

const colors = {
    yellow: '\x1b[33m',
    cyan: '\x1b[36m',
		magenta: '\x1b[35m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    reset: '\x1b[0m'
};

async function start() {
    const { default: inquirer } = await inquirerPromise;
    let running = true;

    while (running) {
        const { mainMenuChoice } = await inquirer.prompt([
            {
                type: 'list',
                name: 'mainMenuChoice',
                message: `${colors.yellow}--- GLAVNI MENI ---${colors.reset}`,
                choices: [
                    { name: 'Jednostavni izvestaji', value: 'simple' },
                    { name: `Kompleksni izvestaji`, value: 'complex' },
                    { name: `Transakcije`, value: 'transaction' }, 
										new inquirer.Separator(), 
                    { name: 'Izlaz iz aplikacije', value: 'exit' }
                ]
            }
        ]);

        switch (mainMenuChoice) {
            case 'simple':
                await handleSimpleReportsMenu(inquirer);
                break;
            case 'complex':
                await handleComplexReportsMenu(inquirer);
                break;
            case 'transaction':
                await handleTransactionMenu(inquirer);
                break;
            case 'exit':
                running = false; 
                break;
        }
    }
}

async function handleSimpleReportsMenu(inquirer) {
    const { simpleReportChoice } = await inquirer.prompt([
        {
            type: 'list',
            name: 'simpleReportChoice',
            message: `${colors.cyan}--- Podmeni: Jednostavni Izvestaji ---${colors.reset}`,
            choices: [
                { name: 'Prikazi prosecnu platu po specijalizaciji', value: 'avgSalary' },
                { name: 'Prikazi broj zaposlenih po firmi', value: 'employeeCount' },
                new inquirer.Separator(),
                { name: 'Nazad na glavni meni', value: 'back' }
            ]
        }
    ]);

    try {
        switch (simpleReportChoice) {
            case 'avgSalary':
                const salaryReport = await simpleService.getAverageSalaryReport();
                console.log("\n--- Izvestaj: Prosecna plata po specijalizaciji ---");
                console.table(salaryReport);
                break;
            case 'employeeCount':
                const employeeReport = await simpleService.getEmployeeCountReport();
                console.log("\n--- Izvestaj: Broj zaposlenih po firmi ---");
                console.table(employeeReport);
                break;
            case 'back':
                return; 
        }
    } catch (error) {
        console.error(`${colors.red}Greska: ${error.message}${colors.reset}`);
    }
}
async function handleComplexReportsMenu(inquirer) {
    const { complexReportChoice } = await inquirer.prompt([
        {
            type: 'list',
            name: 'complexReportChoice',
            message: `${colors.magenta}--- Podmeni: Kompleksni Izvestaji ---${colors.reset}`,
            choices: [
                { name: 'Prikazi aktivna vozila i vozace sa platom > 60k', value: 'activeVehicles' },
                { name: 'Prikazi statistiku firmi sa > 2 majstora', value: 'companyStats' },
                new inquirer.Separator(),
                { name: 'Nazad na glavni meni', value: 'back' }
            ]
        }
    ]);

    try {
        switch (complexReportChoice) {
            case 'activeVehicles':
                const vehicleReport = await complexService.getActiveVehiclesReport();
                console.log("\n--- Izvestaj: Aktivna vozila i vozaci ---");
                console.table(vehicleReport);
                break;
            case 'companyStats':
                const statsReport = await complexService.getCompanyStatisticsReport();
                console.log("\n--- Izvestaj: Statistika firmi ---");
                console.table(statsReport);
                break;
            case 'back':
                return;
        }
    } catch (error) {
        console.error(`${colors.red}Greska: ${error.message}${colors.reset}`);
    }
}
async function handleTransactionMenu(inquirer) {
    const { transactionChoice } = await inquirer.prompt([
        {
            type: 'list',
            name: 'transactionChoice',
            message: `${colors.green}--- Podmeni: Transakcije ---${colors.reset}`,
            choices: [
                { name: 'Zaposli novog majstora i dodeli mu vozilo', value: 'hireWorker' },
                new inquirer.Separator(),
                { name: 'Nazad na glavni meni', value: 'back' }
            ]
        }
    ]);

    if (transactionChoice === 'hireWorker') {
        try {
            console.log('\nUnesite podatke za novog radnika:');
            
            const answers = await inquirer.prompt([
                {
                    type: 'input',
                    name: 'jmbg',
                    message: 'Unesite JMBG (13 cifara):',
                    validate: function(value) {
                        return value.length === 13 && /^\d+$/.test(value) ? true : 'JMBG mora imati tacno 13 cifara.';
                    }
                },
                {
                    type: 'input',
                    name: 'ime',
                    message: 'Unesite ime:',
                    validate: (value) => { return value.trim() !== '' ? true : 'Ovo polje ne sme biti prazno.'; }
                },
                {
                    type: 'input',
                    name: 'prezime',
                    message: 'Unesite prezime:',
                    validate: (value) => { return value.trim() !== '' ? true : 'Ovo polje ne sme biti prazno.'; }
                },
                {
                    type: 'input',
                    name: 'plata',
                    message: 'Unesite platu (RSD):',
                    validate: function(value) {
                        return !isNaN(parseFloat(value)) && isFinite(value) ? true : 'Molimo unesite validan broj.';
                    },
                    filter: Number 
                },
                {
                    type: 'list', 
                    name: 'firmaPib',
                    message: 'Izaberite firmu:',
                    choices: [
                        { name: 'Zidar d.o.o.', value: '111222333' },
                        { name: 'Beton-Staza a.d.', value: '444555666' }
                    ]
                },
                {
                    type: 'input',
                    name: 'specijalizacija',
                    message: 'Unesite specijalizaciju majstora (npr. Zidar, Keramicar):',
                    validate: (value) => { return value.trim() !== '' ? true : 'Ovo polje ne sme biti prazno.'; }
                }
            ]);

            console.log('\nPokrecem transakciju...');
            
            const successMessage = await transactionService.hireWorkerAndAssignVehicle(
                answers.jmbg,
                answers.ime,
                answers.prezime,
                answers.plata,
                answers.firmaPib,
                answers.specijalizacija
            );
            
            console.log(`\n${colors.green}${successMessage}${colors.reset}`);

        } catch (error) {
            console.error(`\n${colors.red}Transakcija neuspesna: ${error.message}${colors.reset}`);
        }
    }
}

module.exports = { start };