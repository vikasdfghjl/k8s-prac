import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import connectDB from './config/db';
import taskRoutes from './routes/taskRoutes';
import userRoutes from './routes/userRoutes';
import { protect } from './middlewares/authMiddleware';
import client from 'prom-client';


dotenv.config();

// Prometheus metrics setup
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Public routes
app.use('/api/users', userRoutes);

// Protected routes
// app.use('/api', protect, taskRoutes);

// Middleware to temporarily un-protected routes
app.use('/api', taskRoutes);


app.get('/', (req, res) => {
  res.status(200).send('Welcome to ToToDo backend');
});

// prometheus metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

// Connect to MongoDB
connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}).catch((error) => {
  console.error('Error starting the server:', error);
});