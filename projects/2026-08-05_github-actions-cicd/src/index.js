const axios = require('axios');

/**
 * Classe pour interagir avec une API publique
 */
class APIClient {
  constructor(baseURL = 'https://jsonplaceholder.typicode.com') {
    this.client = axios.create({ baseURL });
  }

  /**
   * Récupère une liste d'utilisateurs
   */
  async getUsers() {
    const response = await this.client.get('/users');
    return response.data;
  }

  /**
   * Récupère un utilisateur par ID
   */
  async getUserById(id) {
    if (!id || id < 1) {
      throw new Error('ID doit être un nombre positif');
    }
    const response = await this.client.get(`/users/${id}`);
    return response.data;
  }

  /**
   * Récupère les posts d'un utilisateur
   */
  async getUserPosts(userId) {
    if (!userId || userId < 1) {
      throw new Error('userId doit être un nombre positif');
    }
    const response = await this.client.get(`/posts?userId=${userId}`);
    return response.data;
  }

  /**
   * Calcule le nombre total de posts
   */
  async getTotalPostCount() {
    const response = await this.client.get('/posts');
    return response.data.length;
  }
}

/**
 * Utilitaire pour traiter les données
 */
function calculateStats(users) {
  if (!users || users.length === 0) {
    return { count: 0, averagePostCount: 0 };
  }

  return {
    count: users.length,
    averagePostCount: Math.round(users.length / 10),
  };
}

module.exports = { APIClient, calculateStats };
