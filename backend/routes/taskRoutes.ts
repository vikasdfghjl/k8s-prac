import express from 'express';
import { createTask, getTasks, updateTask, deleteTask } from '../controllers/taskcontroller';

const router = express.Router();
// /api
router.post('/tasks', createTask);
router.get('/tasks', getTasks);
router.patch('/tasks/:uuid', updateTask);
router.delete('/tasks/:uuid', deleteTask);

export default router;