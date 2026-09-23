import os
import json
import logging
from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
import psycopg2
from psycopg2.extras import RealDictCursor
import redis
from datetime import datetime
from models import UserCreate, User

app = FastAPI(title="User Service", version="1.0.0")

# Configuration
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_USER = os.getenv('DB_USER', 'devops')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'password')
DB_NAME = os.getenv('DB_NAME', 'microservices_db')
DB_PORT = os.getenv('DB_PORT', '5432')

REDIS_HOST = os.getenv('REDIS_HOST', 'localhost')
REDIS_PORT = int(os.getenv('REDIS_PORT', '6379'))

SERVICE_NAME = os.getenv('SERVICE_NAME', 'user-service')
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')

# Logging
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(SERVICE_NAME)

# Redis connection
try:
    redis_client = redis.Redis(
        host=REDIS_HOST,
        port=REDIS_PORT,
        decode_responses=True,
        socket_connect_timeout=5
    )
    redis_client.ping()
    logger.info("Connected to Redis")
except Exception as e:
    logger.warning(f"Redis connection failed: {e}")
    redis_client = None

def get_db_connection():
    """Create database connection"""
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            port=DB_PORT,
            connect_timeout=5
        )
        return conn
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        return None

@app.get('/health')
def health_check():
    """Health check endpoint"""
    db_ok = False
    redis_ok = False

    try:
        conn = get_db_connection()
        if conn:
            conn.close()
            db_ok = True
    except:
        pass

    try:
        if redis_client:
            redis_client.ping()
            redis_ok = True
    except:
        pass

    return {
        'status': 'healthy' if (db_ok and redis_ok) else 'degraded',
        'service': SERVICE_NAME,
        'database': 'ok' if db_ok else 'error',
        'cache': 'ok' if redis_ok else 'error',
        'timestamp': datetime.utcnow().isoformat()
    }

@app.get('/')
def root():
    """Service info"""
    return {
        'service': SERVICE_NAME,
        'version': '1.0.0',
        'endpoints': {
            'health': 'GET /health',
            'users_list': 'GET /users',
            'user_create': 'POST /users',
            'user_detail': 'GET /users/{id}'
        }
    }

@app.get('/users')
def list_users():
    """List all users with caching"""
    cache_key = 'users:all'

    # Try to get from cache
    if redis_client:
        try:
            cached = redis_client.get(cache_key)
            if cached:
                logger.info("Users retrieved from cache")
                return json.loads(cached)
        except Exception as e:
            logger.warning(f"Cache read error: {e}")

    # Query database
    conn = get_db_connection()
    if not conn:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database unavailable"
        )

    try:
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute('SELECT id, name, email, created_at FROM users ORDER BY created_at DESC')
        users = cursor.fetchall()
        cursor.close()

        result = [dict(u) for u in users]

        # Cache the result
        if redis_client:
            try:
                redis_client.setex(cache_key, 300, json.dumps(result, default=str))
                logger.info("Users cached for 5 minutes")
            except Exception as e:
                logger.warning(f"Cache write error: {e}")

        logger.info(f"Retrieved {len(result)} users from database")
        return result
    finally:
        conn.close()

@app.post('/users', status_code=status.HTTP_201_CREATED)
def create_user(user: UserCreate):
    """Create a new user"""
    conn = get_db_connection()
    if not conn:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database unavailable"
        )

    try:
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute(
            'INSERT INTO users (name, email, created_at) VALUES (%s, %s, NOW()) RETURNING id, name, email, created_at',
            (user.name, user.email)
        )
        new_user = cursor.fetchone()
        conn.commit()

        # Invalidate cache
        if redis_client:
            try:
                redis_client.delete('users:all')
            except:
                pass

        logger.info(f"User created: {user.name} ({user.email})")
        return dict(new_user)
    except psycopg2.IntegrityError:
        conn.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already exists"
        )
    except Exception as e:
        conn.rollback()
        logger.error(f"Error creating user: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error creating user"
        )
    finally:
        conn.close()

@app.get('/users/{user_id}')
def get_user(user_id: int):
    """Get user by ID"""
    cache_key = f'user:{user_id}'

    # Try cache
    if redis_client:
        try:
            cached = redis_client.get(cache_key)
            if cached:
                logger.info(f"User {user_id} retrieved from cache")
                return json.loads(cached)
        except:
            pass

    conn = get_db_connection()
    if not conn:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database unavailable"
        )

    try:
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute(
            'SELECT id, name, email, created_at FROM users WHERE id = %s',
            (user_id,)
        )
        user = cursor.fetchone()
        cursor.close()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        result = dict(user)

        # Cache
        if redis_client:
            try:
                redis_client.setex(cache_key, 300, json.dumps(result, default=str))
            except:
                pass

        return result
    finally:
        conn.close()
