-- Créer la table todos
CREATE TABLE IF NOT EXISTS todos (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Créer un index sur created_at pour les performances
CREATE INDEX IF NOT EXISTS idx_todos_created_at ON todos(created_at DESC);

-- Insérer quelques données de test
INSERT INTO todos (title, completed) VALUES
    ('Apprendre Docker', false),
    ('Créer une API Node.js', false),
    ('Configurer PostgreSQL', true),
    ('Déployer avec Docker Compose', false)
ON CONFLICT DO NOTHING;

-- Afficher les données insérées
SELECT * FROM todos;
