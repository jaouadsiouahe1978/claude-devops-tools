-- Créer la table users
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Créer l'index sur email
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Insérer des données de test
INSERT INTO users (name, email) VALUES
  ('Alice Martin', 'alice@example.com'),
  ('Bob Dupont', 'bob@example.com'),
  ('Charlie Leclerc', 'charlie@example.com'),
  ('Diana Williams', 'diana@example.com'),
  ('Eve Johnson', 'eve@example.com')
ON CONFLICT (email) DO NOTHING;

-- Créer la table de logs
CREATE TABLE IF NOT EXISTS app_logs (
  id SERIAL PRIMARY KEY,
  level VARCHAR(50),
  message TEXT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Créer l'index sur timestamp
CREATE INDEX IF NOT EXISTS idx_logs_timestamp ON app_logs(timestamp DESC);

-- Afficher les tables créées
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
