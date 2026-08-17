-- PostgreSQL Initialization Script for Multi-Container Application
-- This script is automatically executed when the container starts

-- Create Items Table
CREATE TABLE IF NOT EXISTS items (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_status CHECK (status IN ('pending', 'in-progress', 'completed'))
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_items_status ON items(status);
CREATE INDEX IF NOT EXISTS idx_items_created_at ON items(created_at DESC);

-- Insert sample data
INSERT INTO items (title, description, status) VALUES
    ('Setup Docker Compose', 'Learn how to orchestrate multiple containers with docker-compose.yml', 'completed'),
    ('Configure Nginx Reverse Proxy', 'Setup Nginx to proxy requests to Flask backend', 'completed'),
    ('Create Flask API Endpoints', 'Implement REST API for CRUD operations', 'in-progress'),
    ('Connect to PostgreSQL', 'Setup database connection with SQLAlchemy ORM', 'in-progress'),
    ('Add Health Checks', 'Implement health check endpoints for all services', 'pending'),
    ('Setup Volume Management', 'Configure persistent data storage for PostgreSQL', 'pending'),
    ('Implement Authentication', 'Add JWT token-based authentication to API', 'pending'),
    ('Deploy with Docker Registry', 'Push images to Docker registry and pull in production', 'pending')
ON CONFLICT DO NOTHING;

-- Create a view for statistics
CREATE OR REPLACE VIEW items_stats AS
SELECT
    COUNT(*) as total_items,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_count,
    COUNT(CASE WHEN status = 'in-progress' THEN 1 END) as in_progress_count,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_count
FROM items;

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON items TO devops;
GRANT SELECT ON items_stats TO devops;
GRANT USAGE, SELECT ON SEQUENCE items_id_seq TO devops;
