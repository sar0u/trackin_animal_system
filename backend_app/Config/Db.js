const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host:     process.env.DB_HOST     || 'localhost',
  port:     process.env.DB_PORT     || 3306,
  database: process.env.DB_NAME     || 'dz_cheptel_db_1',
  user:     process.env.DB_USER     || 'root',
  password: process.env.DB_PASSWORD || 'Q7v!pA3rXz#9mT2s',
  waitForConnections: true,
  connectionLimit: 10,
});

module.exports = pool;
 