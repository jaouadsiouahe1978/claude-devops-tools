const express = require('express');
const { MongoClient } = require('mongodb');
const redis = require('redis');
const cors = require('cors');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

let mongoClient;
let redisClient;
let db;

app.use(cors());
app.use(express.json());

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/blog_db';
const REDIS_URL = process.env.REDIS_URL || 'redis://localhost:6379';

// Initialiser les connexions
async function initializeConnections() {
  try {
    // Connexion MongoDB
    mongoClient = new MongoClient(MONGODB_URI);
    await mongoClient.connect();
    db = mongoClient.db('blog_db');
    console.log('✅ Connecté à MongoDB');

    // Connexion Redis
    redisClient = redis.createClient({
      url: REDIS_URL,
      socket: {
        reconnectStrategy: (retries) => Math.min(retries * 50, 500)
      }
    });

    redisClient.on('error', (err) => console.error('Redis Error:', err));
    await redisClient.connect();
    console.log('✅ Connecté à Redis');

  } catch (error) {
    console.error('❌ Erreur de connexion:', error);
    process.exit(1);
  }
}

// Route santé
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Créer un article
app.post('/api/posts', async (req, res) => {
  try {
    const { title, content, author } = req.body;

    if (!title || !content || !author) {
      return res.status(400).json({ error: 'Titre, contenu et auteur requis' });
    }

    const post = {
      title,
      content,
      author,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const result = await db.collection('posts').insertOne(post);

    // Invalider le cache
    await redisClient.del('all_posts');

    res.status(201).json({
      id: result.insertedId,
      ...post
    });
  } catch (error) {
    console.error('Erreur lors de la création:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Lister tous les articles
app.get('/api/posts', async (req, res) => {
  try {
    // Vérifier le cache
    const cached = await redisClient.get('all_posts');
    if (cached) {
      console.log('📦 Articles depuis le cache Redis');
      return res.json(JSON.parse(cached));
    }

    const posts = await db.collection('posts').find({}).toArray();

    // Mettre en cache pour 5 minutes
    await redisClient.setEx('all_posts', 300, JSON.stringify(posts));

    console.log('📊 Articles depuis MongoDB');
    res.json(posts);
  } catch (error) {
    console.error('Erreur lors de la récupération:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Obtenir un article spécifique
app.get('/api/posts/:id', async (req, res) => {
  try {
    const { ObjectId } = require('mongodb');

    // Vérifier le cache
    const cached = await redisClient.get(`post_${req.params.id}`);
    if (cached) {
      console.log(`📦 Article ${req.params.id} depuis le cache Redis`);
      return res.json(JSON.parse(cached));
    }

    const post = await db.collection('posts').findOne({
      _id: new ObjectId(req.params.id)
    });

    if (!post) {
      return res.status(404).json({ error: 'Article non trouvé' });
    }

    // Mettre en cache
    await redisClient.setEx(`post_${req.params.id}`, 300, JSON.stringify(post));

    console.log(`📊 Article ${req.params.id} depuis MongoDB`);
    res.json(post);
  } catch (error) {
    console.error('Erreur lors de la récupération:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Mettre à jour un article
app.put('/api/posts/:id', async (req, res) => {
  try {
    const { ObjectId } = require('mongodb');
    const { title, content, author } = req.body;

    const result = await db.collection('posts').updateOne(
      { _id: new ObjectId(req.params.id) },
      {
        $set: {
          title,
          content,
          author,
          updatedAt: new Date()
        }
      }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ error: 'Article non trouvé' });
    }

    // Invalider les caches
    await redisClient.del('all_posts');
    await redisClient.del(`post_${req.params.id}`);

    res.json({ message: 'Article mis à jour' });
  } catch (error) {
    console.error('Erreur lors de la mise à jour:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Supprimer un article
app.delete('/api/posts/:id', async (req, res) => {
  try {
    const { ObjectId } = require('mongodb');

    const result = await db.collection('posts').deleteOne({
      _id: new ObjectId(req.params.id)
    });

    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Article non trouvé' });
    }

    // Invalider les caches
    await redisClient.del('all_posts');
    await redisClient.del(`post_${req.params.id}`);

    res.json({ message: 'Article supprimé' });
  } catch (error) {
    console.error('Erreur lors de la suppression:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Page HTML simple pour visualiser le blog
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="fr">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Blog Platform - Docker Compose</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          min-height: 100vh;
          padding: 20px;
        }
        .container { max-width: 800px; margin: 0 auto; }
        header {
          background: white;
          padding: 30px;
          border-radius: 10px;
          box-shadow: 0 10px 30px rgba(0,0,0,0.2);
          margin-bottom: 30px;
        }
        h1 { color: #333; margin-bottom: 10px; }
        .status {
          display: flex;
          gap: 15px;
          margin-top: 20px;
          flex-wrap: wrap;
        }
        .badge {
          padding: 8px 15px;
          border-radius: 20px;
          font-size: 13px;
          font-weight: bold;
          color: white;
        }
        .badge.success { background: #4caf50; }
        .badge.info { background: #2196f3; }
        form {
          background: white;
          padding: 20px;
          border-radius: 10px;
          box-shadow: 0 10px 30px rgba(0,0,0,0.2);
          margin-bottom: 30px;
        }
        input, textarea {
          width: 100%;
          padding: 10px;
          margin: 10px 0;
          border: 1px solid #ddd;
          border-radius: 5px;
          font-family: inherit;
        }
        textarea { min-height: 100px; }
        button {
          background: #667eea;
          color: white;
          padding: 10px 20px;
          border: none;
          border-radius: 5px;
          cursor: pointer;
          font-weight: bold;
        }
        button:hover { background: #764ba2; }
        .posts { margin-top: 30px; }
        .post {
          background: white;
          padding: 20px;
          border-radius: 10px;
          box-shadow: 0 10px 30px rgba(0,0,0,0.2);
          margin-bottom: 20px;
        }
        .post h2 { color: #333; margin-bottom: 10px; }
        .post-meta { color: #666; font-size: 14px; margin-bottom: 10px; }
        .post-content { color: #555; line-height: 1.6; }
        .loading { text-align: center; color: white; font-size: 18px; }
      </style>
    </head>
    <body>
      <div class="container">
        <header>
          <h1>🚀 Blog Platform - Docker Compose</h1>
          <div class="status">
            <span class="badge success">✓ API Online</span>
            <span class="badge info">MongoDB Connected</span>
            <span class="badge info">Redis Cached</span>
          </div>
        </header>

        <form id="postForm">
          <h2>Créer un nouvel article</h2>
          <input type="text" id="title" placeholder="Titre de l'article" required>
          <input type="text" id="author" placeholder="Auteur" required>
          <textarea id="content" placeholder="Contenu de l'article" required></textarea>
          <button type="submit">Publier</button>
        </form>

        <div class="posts">
          <h2 style="color: white; margin-bottom: 20px;">📚 Articles récents</h2>
          <div id="postsList" class="loading">Chargement des articles...</div>
        </div>
      </div>

      <script>
        const API_URL = '/api/posts';

        async function loadPosts() {
          try {
            const res = await fetch(API_URL);
            const posts = await res.json();
            const postsList = document.getElementById('postsList');

            if (posts.length === 0) {
              postsList.innerHTML = '<p class="loading">Aucun article pour le moment</p>';
              return;
            }

            postsList.innerHTML = posts.map(post => \`
              <div class="post">
                <h2>\${post.title}</h2>
                <div class="post-meta">Par \${post.author} • \${new Date(post.createdAt).toLocaleDateString('fr-FR')}</div>
                <div class="post-content">\${post.content}</div>
              </div>
            \`).join('');
          } catch (error) {
            console.error('Erreur:', error);
            document.getElementById('postsList').innerHTML = '<p class="loading">Erreur lors du chargement</p>';
          }
        }

        document.getElementById('postForm').addEventListener('submit', async (e) => {
          e.preventDefault();

          try {
            const res = await fetch(API_URL, {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                title: document.getElementById('title').value,
                author: document.getElementById('author').value,
                content: document.getElementById('content').value
              })
            });

            if (res.ok) {
              document.getElementById('postForm').reset();
              loadPosts();
              alert('Article publié avec succès!');
            }
          } catch (error) {
            alert('Erreur: ' + error.message);
          }
        });

        loadPosts();
        setInterval(loadPosts, 30000);
      </script>
    </body>
    </html>
  `);
});

// Démarrer le serveur
app.listen(port, async () => {
  await initializeConnections();
  console.log(`\n🌍 Serveur démarré sur http://localhost:${port}`);
  console.log(`📊 API disponible sur http://localhost:${port}/api/posts`);
  console.log(`💾 MongoDB: ${MONGODB_URI}`);
  console.log(`⚡ Redis: ${REDIS_URL}\n`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('\n🛑 Arrêt du serveur...');
  if (mongoClient) await mongoClient.close();
  if (redisClient) await redisClient.quit();
  process.exit(0);
});
