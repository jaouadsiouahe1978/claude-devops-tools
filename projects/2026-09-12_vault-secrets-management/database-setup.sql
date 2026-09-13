-- PostgreSQL Database Setup for Vault Dynamic Credentials

-- Create a dedicated schema for Vault
CREATE SCHEMA IF NOT EXISTS vault_managed;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create a vault admin user (already created by POSTGRES_USER env, but let's ensure permissions)
GRANT ALL PRIVILEGES ON DATABASE vault_demo TO vaultadmin;
GRANT ALL PRIVILEGES ON SCHEMA public TO vaultadmin;
GRANT ALL PRIVILEGES ON SCHEMA vault_managed TO vaultadmin;

-- Create an application user (will be managed by Vault)
-- This is just a placeholder; Vault will create dynamic users
CREATE ROLE "app_user" WITH LOGIN PASSWORD 'initial_password';
GRANT CONNECT ON DATABASE vault_demo TO "app_user";
GRANT USAGE ON SCHEMA public TO "app_user";
GRANT USAGE ON SCHEMA vault_managed TO "app_user";

-- Create a table to demonstrate access
CREATE TABLE IF NOT EXISTS vault_managed.secrets_audit (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_name VARCHAR(100),
    accessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    secret_name VARCHAR(100),
    action VARCHAR(50)
);

-- Grant select permission on audit table to all roles
GRANT SELECT ON vault_managed.secrets_audit TO "app_user";

-- Create a sample data table
CREATE TABLE IF NOT EXISTS public.customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO public.customers (name, email) VALUES
    ('Alice Johnson', 'alice@example.com'),
    ('Bob Smith', 'bob@example.com'),
    ('Charlie Brown', 'charlie@example.com')
ON CONFLICT DO NOTHING;

-- Grant permissions
GRANT SELECT, INSERT, UPDATE ON public.customers TO "app_user";
GRANT USAGE, SELECT ON SEQUENCE public.customers_id_seq TO "app_user";

-- Create a function to log access
CREATE OR REPLACE FUNCTION log_access(p_user VARCHAR, p_secret VARCHAR)
RETURNS void AS $$
BEGIN
    INSERT INTO vault_managed.secrets_audit (user_name, secret_name, action)
    VALUES (p_user, p_secret, 'READ');
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vault_managed.log_access(VARCHAR, VARCHAR) TO "app_user";

-- Display confirmation
\echo 'PostgreSQL setup completed for Vault dynamic credentials!'
\echo 'Schema vault_managed created'
\echo 'Tables created: secrets_audit, customers'
\echo 'Vault admin user vaultadmin ready'
