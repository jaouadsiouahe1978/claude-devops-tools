const { APIClient, calculateStats } = require('../src/index');

// Mock axios
jest.mock('axios');
const axios = require('axios');

describe('APIClient', () => {
  let client;

  beforeEach(() => {
    client = new APIClient();
    jest.clearAllMocks();
  });

  describe('getUsers', () => {
    it('devrait retourner la liste des utilisateurs', async () => {
      const mockUsers = [
        { id: 1, name: 'Alice' },
        { id: 2, name: 'Bob' },
      ];

      axios.create().get.mockResolvedValue({ data: mockUsers });

      const users = await client.getUsers();
      expect(users).toEqual(mockUsers);
    });
  });

  describe('getUserById', () => {
    it('devrait retourner un utilisateur par ID', async () => {
      const mockUser = { id: 1, name: 'Alice', email: 'alice@example.com' };
      axios.create().get.mockResolvedValue({ data: mockUser });

      const user = await client.getUserById(1);
      expect(user).toEqual(mockUser);
    });

    it('devrait lever une erreur si ID est invalide', async () => {
      await expect(client.getUserById(0)).rejects.toThrow('ID doit être un nombre positif');
      await expect(client.getUserById(-1)).rejects.toThrow('ID doit être un nombre positif');
    });

    it('devrait lever une erreur si ID est manquant', async () => {
      await expect(client.getUserById(null)).rejects.toThrow('ID doit être un nombre positif');
    });
  });

  describe('getUserPosts', () => {
    it('devrait retourner les posts d\'un utilisateur', async () => {
      const mockPosts = [
        { id: 1, userId: 1, title: 'Post 1' },
        { id: 2, userId: 1, title: 'Post 2' },
      ];

      axios.create().get.mockResolvedValue({ data: mockPosts });

      const posts = await client.getUserPosts(1);
      expect(posts).toEqual(mockPosts);
    });

    it('devrait lever une erreur si userId est invalide', async () => {
      await expect(client.getUserPosts(0)).rejects.toThrow('userId doit être un nombre positif');
      await expect(client.getUserPosts(-5)).rejects.toThrow('userId doit être un nombre positif');
    });
  });

  describe('getTotalPostCount', () => {
    it('devrait retourner le nombre total de posts', async () => {
      const mockPosts = Array(100).fill(null).map((_, i) => ({ id: i + 1 }));
      axios.create().get.mockResolvedValue({ data: mockPosts });

      const count = await client.getTotalPostCount();
      expect(count).toBe(100);
    });
  });
});

describe('calculateStats', () => {
  it('devrait calculer les stats pour une liste d\'utilisateurs', () => {
    const users = Array(10).fill(null).map((_, i) => ({ id: i + 1, name: `User ${i + 1}` }));
    const stats = calculateStats(users);

    expect(stats.count).toBe(10);
    expect(stats.averagePostCount).toBe(1);
  });

  it('devrait retourner des stats vides pour une liste vide', () => {
    const stats = calculateStats([]);
    expect(stats.count).toBe(0);
    expect(stats.averagePostCount).toBe(0);
  });

  it('devrait retourner des stats vides si null', () => {
    const stats = calculateStats(null);
    expect(stats.count).toBe(0);
    expect(stats.averagePostCount).toBe(0);
  });
});
