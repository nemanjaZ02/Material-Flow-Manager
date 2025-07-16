require('dotenv').config();
const { Pool } = require('pg');

const appDbConfig = {
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT,
};

const pool = new Pool(appDbConfig);

module.exports = {
    query: (text, params) => pool.query(text, params),
    pool 
};