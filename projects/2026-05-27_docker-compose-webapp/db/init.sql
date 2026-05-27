-- Créer l'extension UUID pour les IDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table des utilisateurs
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour les recherches par email
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Table des logs d'activité
CREATE TABLE IF NOT EXISTS activity_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour les recherches par user_id
CREATE INDEX IF NOT EXISTS idx_activity_user_id ON activity_logs(user_id);

-- Données de test
INSERT INTO users (name, email) VALUES
    ('Alice Dupont', 'alice@example.com'),
    ('Bob Martin', 'bob@example.com'),
    ('Charlie Brown', 'charlie@example.com')
ON CONFLICT (email) DO NOTHING;

-- Enregistrer l'initialisation
INSERT INTO activity_logs (user_id, action, description)
SELECT id, 'CREATED', 'User created during database initialization'
FROM users
ON CONFLICT DO NOTHING;

-- Afficher les données insérées
SELECT * FROM users;
