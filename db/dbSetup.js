require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

async function initializeDatabase() {
    const dbName = process.env.DB_NAME;
    let maintenancePool;
    let appPool;

    try {
        const maintenanceConfig = {
            user: process.env.DB_USER,
            host: process.env.DB_HOST,
            password: process.env.DB_PASSWORD,
            port: process.env.DB_PORT,
            database: 'postgres', 
        };
        maintenancePool = new Pool(maintenanceConfig);
        const client = await maintenancePool.connect();
        
        const res = await client.query(`SELECT 1 FROM pg_database WHERE datname = $1`, [dbName]);
        if (res.rowCount === 0) {
            console.log(`Baza '${dbName}' ne postoji, kreiram je...`);
            await client.query(`CREATE DATABASE "${dbName}"`);
        }
        client.release();
    } catch (err) {
        console.error('Greska prilikom provere/kreiranja baze:', err);
        throw err; 
    } finally {
        if (maintenancePool) {
            await maintenancePool.end();
        }
    }

    try {
        const appDbConfig = {
            user: process.env.DB_USER,
            host: process.env.DB_HOST,
            database: dbName, 
            password: process.env.DB_PASSWORD,
            port: process.env.DB_PORT,
        };
        appPool = new Pool(appDbConfig);

        const schemaSql = fs.readFileSync(path.join(__dirname, 'usedDB.sql'), 'utf-8');
        await appPool.query(schemaSql);

        const seedSql = fs.readFileSync(path.join(__dirname, 'seed.sql'), 'utf-8');
        await appPool.query(seedSql);
        
        console.log("Baza je uspesno postavljena i popunjena podacima.");

    } catch (err) {
        if (!err.message.includes('already exists')) {
            console.error('Greska prilikom primene seme ili podataka:', err);
            throw err;
        } else {
            console.log("Info: Sema vec postoji. Pokusavam da popunim podatke...");
            try {
                const seedSql = fs.readFileSync(path.join(__dirname, 'seed.sql'), 'utf-8');
                await appPool.query(seedSql);
                console.log("Podaci su uspesno osvezeni.");
            } catch (seedErr) {
                 console.error('Greska prilikom popunjavanja podataka:', seedErr);
                 throw seedErr;
            }
        }
    } finally {
        if (appPool) {
            await appPool.end(); 
        }
    }
}

module.exports = {
    initializeDatabase
};