-- Initialize the items table
CREATE TABLE IF NOT EXISTS items (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO items (name, description) VALUES
  ('Docker Basics', 'Learn containerization with Docker'),
  ('Docker Compose', 'Orchestrate multi-container applications'),
  ('PostgreSQL', 'Relational database in a container')
ON CONFLICT DO NOTHING;

-- Create an index for faster queries
CREATE INDEX idx_items_created_at ON items(created_at DESC);
