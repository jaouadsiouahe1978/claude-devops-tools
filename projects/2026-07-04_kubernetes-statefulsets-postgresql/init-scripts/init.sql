-- Initialization script for PostgreSQL StatefulSet
-- This script is run only once during the initial setup of the postgres-0 Pod

-- Create replication user if not exists
CREATE USER IF NOT EXISTS replication WITH REPLICATION ENCRYPTED PASSWORD 'replication-password-2026';

-- Create tables in devops_db
CREATE TABLE IF NOT EXISTS system_metrics (
    id BIGSERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    pod_name VARCHAR(255) NOT NULL,
    cpu_usage FLOAT NOT NULL,
    memory_usage FLOAT NOT NULL,
    disk_usage FLOAT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS application_logs (
    id BIGSERIAL PRIMARY KEY,
    level VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    source VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_system_metrics_timestamp ON system_metrics(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_system_metrics_pod ON system_metrics(pod_name);
CREATE INDEX IF NOT EXISTS idx_application_logs_level ON application_logs(level);
CREATE INDEX IF NOT EXISTS idx_application_logs_created ON application_logs(created_at DESC);

-- Insert sample data
INSERT INTO system_metrics (pod_name, cpu_usage, memory_usage, disk_usage)
VALUES
    ('postgres-0', 15.5, 42.3, 28.7),
    ('postgres-1', 12.2, 38.1, 25.3),
    ('postgres-2', 18.9, 45.6, 30.2);

INSERT INTO application_logs (level, message, source)
VALUES
    ('INFO', 'PostgreSQL StatefulSet initialized successfully', 'devops-setup'),
    ('INFO', 'Replication user created', 'devops-setup'),
    ('INFO', 'Schema and tables created', 'devops-setup');

-- Grant privileges to replication user
GRANT USAGE ON SCHEMA public TO replication;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO replication;

-- Display confirmation
SELECT 'PostgreSQL initialization completed!' as status;
