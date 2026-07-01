-- Créer la table users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(80) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Créer l'index sur username
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- Insérer des données de test
INSERT INTO users (username, email) VALUES
    ('devops_admin', 'admin@devops.local'),
    ('jaouad_sre', 'jaouad@sre.local'),
    ('docker_fan', 'docker@devops.local')
ON CONFLICT DO NOTHING;

-- Vérifier les données
SELECT 'Database initialized successfully' as status;
