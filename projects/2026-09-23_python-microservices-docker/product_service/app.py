import os
import json
import logging
from fastapi import FastAPI, HTTPException, status
import psycopg2
from psycopg2.extras import RealDictCursor
import redis
from datetime import datetime
from models import ProductCreate, Product

app = FastAPI(title="Product Service", version="1.0.0")

# Configuration
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_USER = os.getenv('DB_USER', 'devops')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'password')
DB_NAME = os.getenv('DB_NAME', 'microservices_db')
DB_PORT = os.getenv('DB_PORT', '5432')

REDIS_HOST = os.getenv('REDIS_HOST', 'localhost')
REDIS_PORT = int(os.getenv('REDIS_PORT', '6379'))

SERVICE_NAME = os.getenv('SERVICE_NAME', 'product-service')
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
            'products_list': 'GET /products',
            'product_create': 'POST /products',
            'product_detail': 'GET /products/{id}'
        }
    }

@app.get('/products')
def list_products():
    """List all products with caching"""
    cache_key = 'products:all'

    # Try to get from cache
    if redis_client:
        try:
            cached = redis_client.get(cache_key)
            if cached:
                logger.info("Products retrieved from cache")
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
        cursor.execute('SELECT id, name, price, description, created_at FROM products ORDER BY created_at DESC')
        products = cursor.fetchall()
        cursor.close()

        result = [dict(p) for p in products]

        # Cache the result
        if redis_client:
            try:
                redis_client.setex(cache_key, 300, json.dumps(result, default=str))
                logger.info("Products cached for 5 minutes")
            except Exception as e:
                logger.warning(f"Cache write error: {e}")

        logger.info(f"Retrieved {len(result)} products from database")
        return result
    finally:
        conn.close()

@app.post('/products', status_code=status.HTTP_201_CREATED)
def create_product(product: ProductCreate):
    """Create a new product"""
    conn = get_db_connection()
    if not conn:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Database unavailable"
        )

    try:
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        cursor.execute(
            'INSERT INTO products (name, price, description, created_at) VALUES (%s, %s, %s, NOW()) RETURNING id, name, price, description, created_at',
            (product.name, product.price, product.description)
        )
        new_product = cursor.fetchone()
        conn.commit()

        # Invalidate cache
        if redis_client:
            try:
                redis_client.delete('products:all')
            except:
                pass

        logger.info(f"Product created: {product.name} (${product.price})")
        return dict(new_product)
    except Exception as e:
        conn.rollback()
        logger.error(f"Error creating product: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error creating product"
        )
    finally:
        conn.close()

@app.get('/products/{product_id}')
def get_product(product_id: int):
    """Get product by ID"""
    cache_key = f'product:{product_id}'

    # Try cache
    if redis_client:
        try:
            cached = redis_client.get(cache_key)
            if cached:
                logger.info(f"Product {product_id} retrieved from cache")
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
            'SELECT id, name, price, description, created_at FROM products WHERE id = %s',
            (product_id,)
        )
        product = cursor.fetchone()
        cursor.close()

        if not product:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Product not found"
            )

        result = dict(product)

        # Cache
        if redis_client:
            try:
                redis_client.setex(cache_key, 300, json.dumps(result, default=str))
            except:
                pass

        return result
    finally:
        conn.close()
