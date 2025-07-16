const { initializeDatabase } = require('./db/dbSetup.js');
const { pool } = require('./db/query.js'); 
const uiHandler = require('./uiHandler.js');

async function main() {
    console.log("Pokretanje aplikacije...");

    try {
        await initializeDatabase();
        console.log("Baza podataka je spremna.");
        await uiHandler.start();
    } catch (error) {
        console.error("\nFatalna greska, aplikacija se gasi:", error.message);
    } finally {
        if (pool) {
            await pool.end();
            console.log('Konekcija sa bazom je zatvorena. Dovidjenja!');
        }
    }
}

main();