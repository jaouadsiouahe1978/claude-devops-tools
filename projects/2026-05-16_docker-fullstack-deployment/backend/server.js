const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Configuration de la connexion PostgreSQL
const pool = new Pool({
  user: process.env.DB_USER || 'devops_user',
  password: process.env.DB_PASSWORD || 'devops_pass',
  host: process.env.DB_HOST || 'postgres',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'devops_db',
});

pool.on('error', (err) => {
  console.error('Erreur de pool PostgreSQL:', err);
});

// Routes
app.get('/api/health', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({
      status: 'OK',
      database: 'Connected',
      timestamp: result.rows[0].now,
    });
  } catch (err) {
    console.error('Erreur health check:', err);
    res.status(500).json({
      status: 'ERROR',
      database: 'Disconnected',
      error: err.message,
    });
  }
});

// GET tous les todos
app.get('/api/todos', async (req, res) => {
  try {
    const result = await pool.query('SELECT id, title, completed, created_at FROM todos ORDER BY created_at DESC');
    res.json({
      success: true,
      data: result.rows,
    });
  } catch (err) {
    console.error('Erreur GET todos:', err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// POST créer un todo
app.post('/api/todos', async (req, res) => {
  const { title } = req.body;
  if (!title) {
    return res.status(400).json({ success: false, error: 'Title is required' });
  }

  try {
    const result = await pool.query(
      'INSERT INTO todos (title, completed) VALUES ($1, $2) RETURNING id, title, completed, created_at',
      [title, false]
    );
    res.status(201).json({
      success: true,
      data: result.rows[0],
    });
  } catch (err) {
    console.error('Erreur POST todo:', err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// PUT mettre à jour un todo
app.put('/api/todos/:id', async (req, res) => {
  const { id } = req.params;
  const { title, completed } = req.body;

  try {
    const result = await pool.query(
      'UPDATE todos SET title = COALESCE($1, title), completed = COALESCE($2, completed) WHERE id = $3 RETURNING *',
      [title, completed, id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Todo not found' });
    }
    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (err) {
    console.error('Erreur PUT todo:', err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// DELETE un todo
app.delete('/api/todos/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM todos WHERE id = $1 RETURNING id', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'Todo not found' });
    }
    res.json({
      success: true,
      message: 'Todo deleted',
      id: id,
    });
  } catch (err) {
    console.error('Erreur DELETE todo:', err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// Lancer le serveur
app.listen(PORT, () => {
  console.log(`🚀 Backend API running on http://localhost:${PORT}`);
  console.log(`📊 Health check available at http://localhost:${PORT}/api/health`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM signal received: closing HTTP server');
  await pool.end();
  process.exit(0);
});
