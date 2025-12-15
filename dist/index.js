"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const redis_1 = require("redis");
const express_1 = __importDefault(require("express"));
const prisma = new client_1.PrismaClient();
let redisClient = null;
function initializeRedis() {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            redisClient = (0, redis_1.createClient)({
                url: process.env.REDIS_URL || 'redis://localhost:6379'
            });
            redisClient.on('error', (err) => console.log('Redis Client Error', err));
            yield redisClient.connect();
            console.log('Redis connected successfully');
        }
        catch (err) {
            console.error('Redis connection failed:', err);
            redisClient = null;
        }
    });
}
const app = (0, express_1.default)();
app.use(express_1.default.json());
// 🏚️ Default Route
app.get('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    res.json({ message: 'Hello from Express Prisma Boilerplate!', redis: redisClient ? 'Connected' : 'Disconnected' });
}));
// Create new user
app.post('/users', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { name, email } = req.body;
        const user = yield prisma.user.create({
            data: {
                name: String(name),
                email: String(email),
                status: "active"
            }
        });
        if (redisClient) {
            yield redisClient.del('users_list');
        }
        res.json({ message: "success", data: user });
    }
    catch (error) {
        res.status(500).json({ message: "error", error: String(error) });
    }
}));
// Get single user
app.get('/users/:id', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        if (redisClient) {
            const cachedUser = yield redisClient.get(`user_${id}`);
            if (cachedUser) {
                console.log(`Cache hit for user ${id}`);
                return res.json({ message: "success", data: JSON.parse(cachedUser), cached: true });
            }
        }
        const user = yield prisma.user.findUnique({
            where: {
                id: Number(id)
            }
        });
        if (redisClient && user) {
            yield redisClient.setEx(`user_${id}`, 3600, JSON.stringify(user));
        }
        res.json({ message: "success", data: user, cached: false });
    }
    catch (error) {
        res.status(500).json({ message: "error", error: String(error) });
    }
}));
// Get all users
app.get('/users', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        if (redisClient) {
            const cachedUsers = yield redisClient.get('users_list');
            if (cachedUsers) {
                console.log('Cache hit for users list');
                return res.json({ message: "success", data: JSON.parse(cachedUsers), cached: true });
            }
        }
        const users = yield prisma.user.findMany();
        if (redisClient && users.length > 0) {
            yield redisClient.setEx('users_list', 1800, JSON.stringify(users));
        }
        res.json({ message: "success", data: users, cached: false });
    }
    catch (error) {
        res.status(500).json({ message: "error", error: String(error) });
    }
}));
// Update user with id
app.patch('/users/:id', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const { name, email } = req.body;
        const user = yield prisma.user.update({
            where: {
                id: Number(id)
            },
            data: {
                name: String(name),
                email: String(email)
            }
        });
        if (redisClient) {
            yield redisClient.del(`user_${id}`);
            yield redisClient.del('users_list');
        }
        res.json({ message: "success", data: user });
    }
    catch (error) {
        res.status(500).json({ message: "error", error: String(error) });
    }
}));
// Delete user with id
app.delete('/users/:id', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        yield prisma.user.delete({
            where: {
                id: Number(id)
            }
        });
        if (redisClient) {
            yield redisClient.del(`user_${id}`);
            yield redisClient.del('users_list');
        }
        res.json({ message: "success" });
    }
    catch (error) {
        res.status(500).json({ message: "error", error: String(error) });
    }
}));
// Health check endpoint
app.get('/health', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const dbHealth = yield prisma.$queryRaw `SELECT 1`;
        const redisHealth = redisClient ? (yield redisClient.ping()) === "PONG" : false;
        res.json({
            message: "API is healthy",
            database: dbHealth ? "connected" : "disconnected",
            redis: redisHealth ? "connected" : "disconnected"
        });
    }
    catch (error) {
        res.status(500).json({
            message: "API is unhealthy",
            error: String(error)
        });
    }
}));
// Start server
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => __awaiter(void 0, void 0, void 0, function* () {
    yield initializeRedis();
    console.log(`Express server is running on port ${PORT}`);
    console.log('Redis status:', redisClient ? 'Connected' : 'Disconnected');
}));
