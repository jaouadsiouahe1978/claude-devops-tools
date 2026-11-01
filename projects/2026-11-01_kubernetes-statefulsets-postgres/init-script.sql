-- Sample initialization script for development
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS logs (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_logs_user_id ON logs(user_id);
CREATE INDEX idx_logs_created_at ON logs(created_at);

-- Insert sample data
INSERT INTO users (username, email) VALUES
  ('jaouad', 'jaouad@example.com'),
  ('devops', 'devops@example.com'),
  ('sysadmin', 'sysadmin@example.com')
ON CONFLICT DO NOTHING;

-- Display data
SELECT 'Users table created with sample data' AS status;
SELECT COUNT(*) as user_count FROM users;
