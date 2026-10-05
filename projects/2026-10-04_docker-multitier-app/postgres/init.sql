-- Initialize PostgreSQL database for DevOps multi-tier app
-- This script runs automatically when the container starts

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Insert sample data
INSERT INTO users (name, email) VALUES
    ('Jaouad SRE', 'jaouad@devops.local'),
    ('DevOps Student', 'student@devops.local'),
    ('Alice Engineer', 'alice@devops.local'),
    ('Bob Admin', 'bob@devops.local')
ON CONFLICT (email) DO NOTHING;

-- Create logs table for app monitoring
CREATE TABLE IF NOT EXISTS app_logs (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    level VARCHAR(20),
    message TEXT,
    source VARCHAR(255)
);

-- Create index for logs
CREATE INDEX IF NOT EXISTS idx_logs_timestamp ON app_logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_logs_level ON app_logs(level);

-- Grant permissions
GRANT USAGE ON SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;
