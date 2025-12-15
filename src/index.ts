import { PrismaClient } from "@prisma/client";
import { createClient } from 'redis';
import express, { Request, Response } from 'express';

const prisma = new PrismaClient();

let redisClient: any = null;

async function initializeRedis() {
  try {
    redisClient = createClient({
      url: process.env.REDIS_URL || 'redis://localhost:6379'
    });

    redisClient.on('error', (err: any) => console.log('Redis Client Error', err));
    await redisClient.connect();
    console.log('Redis connected successfully');
  } catch (err) {
    console.error('Redis connection failed:', err);
    redisClient = null;
  }
}

const app = express();
app.use(express.json());

// 🏚️ Default Route
app.get('/', async (req: Request, res: Response) => {
    res.json({ message: 'Hello from Express Prisma Boilerplate!', redis: redisClient ? 'Connected' : 'Disconnected' });
});

// Create new user
app.post('/users', async (req: Request, res: Response) => {
    try {
      const { name, email } = req.body;
      const user = await prisma.user.create({ 
          data: {
              name: String(name),
              email: String(email),
              status: "active"
          }
      });
      
      if (redisClient) {
        await redisClient.del('users_list');
      }
      
      res.json({ message: "success", data: user });
    } catch (error) {
      res.status(500).json({ message: "error", error: String(error) });
    }
});

// Get single user
app.get('/users/:id', async (req: Request, res: Response) => {
    try {
      const { id } = req.params;
      
      if (redisClient) {
        const cachedUser = await redisClient.get(`user_${id}`);
        if (cachedUser) {
          console.log(`Cache hit for user ${id}`);
          return res.json({ message: "success", data: JSON.parse(cachedUser), cached: true });
        }
      }
      
      const user = await prisma.user.findUnique({
          where: {
              id: Number(id)
          }
      });
      
      if (redisClient && user) {
        await redisClient.setEx(`user_${id}`, 3600, JSON.stringify(user));
      }
      
      res.json({ message: "success", data: user, cached: false });
    } catch (error) {
      res.status(500).json({ message: "error", error: String(error) });
    }
});

// Get all users
app.get('/users', async (req: Request, res: Response) => {
    try {
      if (redisClient) {
        const cachedUsers = await redisClient.get('users_list');
        if (cachedUsers) {
          console.log('Cache hit for users list');
          return res.json({ message: "success", data: JSON.parse(cachedUsers), cached: true });
        }
      }
      
      const users = await prisma.user.findMany();
      
      if (redisClient && users.length > 0) {
        await redisClient.setEx('users_list', 1800, JSON.stringify(users));
      }
      
      res.json({ message: "success", data: users, cached: false });
    } catch (error) {
      res.status(500).json({ message: "error", error: String(error) });
    }
});

// Update user with id
app.patch('/users/:id', async (req: Request, res: Response) => {
    try {
      const { id } = req.params;
      const { name, email } = req.body;
      const user = await prisma.user.update({
          where: {
              id: Number(id)
          },
          data: {
              name: String(name),
              email: String(email)
          }
      });
      
      if (redisClient) {
        await redisClient.del(`user_${id}`);
        await redisClient.del('users_list');
      }
      
      res.json({ message: "success", data: user });
    } catch (error) {
      res.status(500).json({ message: "error", error: String(error) });
    }
});

// Delete user with id
app.delete('/users/:id', async (req: Request, res: Response) => {
    try {
      const { id } = req.params;
      await prisma.user.delete({
          where: {
              id: Number(id)
          }
      });
      
      if (redisClient) {
        await redisClient.del(`user_${id}`);
        await redisClient.del('users_list');
      }
      
      res.json({ message: "success" });
    } catch (error) {
      res.status(500).json({ message: "error", error: String(error) });
    }
});

// Health check endpoint
app.get('/health', async (req: Request, res: Response) => {
    try {
      const dbHealth = await prisma.$queryRaw`SELECT 1`;
      const redisHealth = redisClient ? (await redisClient.ping()) === "PONG" : false;
      
      res.json({ 
        message: "API is healthy",
        database: dbHealth ? "connected" : "disconnected",
        redis: redisHealth ? "connected" : "disconnected"
      });
    } catch (error) {
      res.status(500).json({
        message: "API is unhealthy",
        error: String(error)
      });
    }
});

// Start server
const PORT = process.env.PORT || 4000;
app.listen(PORT, async () => {
    await initializeRedis();
    console.log(`Express server is running on port ${PORT}`);
    console.log('Redis status:', redisClient ? 'Connected' : 'Disconnected');
});
