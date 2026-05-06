const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
});

async function testConnection() {
  try {
    console.log('Testing database connection...');
    const result = await pool.query('SELECT NOW()');
    console.log('✓ Database connected successfully');
    console.log('Current time:', result.rows[0].now);

    const userCount = await pool.query('SELECT COUNT(*) FROM users');
    console.log('✓ Users in database:', userCount.rows[0].count);

    const users = await pool.query('SELECT username, email FROM users');
    console.log('✓ Users:', users.rows);

    process.exit(0);
  } catch (error) {
    console.error('✗ Database connection failed:', error.message);
    process.exit(1);
  }
}

testConnection();
