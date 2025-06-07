import { Request, Response } from 'express';
import { Task } from '../models/task';
import { v4 as uuidv4 } from 'uuid';

// Create a new task
export const createTask = async (req: Request, res: Response) => {
  try {
    const task = new Task({
      ...req.body,
      uuid: req.body.uuid || uuidv4()
    });
    await task.save();
    console.log('Task created:', task);
    res.status(201).send(task);
  } catch (error) {
    console.error('Error creating task:', error);
    res.status(400).send(error);
  }
};

// Get all tasks
export const getTasks = async (req: Request, res: Response) => {
  try {
    const tasks = await Task.find();
    res.status(200).send(tasks);
  } catch (error) {
    console.error('Error fetching tasks:', error);
    res.status(500).send(error);
  }
};

// Update a task
export const updateTask = async (req: Request, res: Response) => {
  try {
    const task = await Task.findOneAndUpdate(
      { uuid: req.params.uuid },
      req.body,
      { new: true }
    );
    if (!task) {
      console.log('Task not found:', req.params.uuid);
      res.status(404).json({ message: 'Task not found' });
    } else {
      console.log('Task updated:', task);
      res.send(task);
    }
  } catch (error) {
    console.error('Error updating task:', error);
    res.status(400).send(error);
  }
};

// Delete a task
export const deleteTask = async (req: Request, res: Response) => {
  try {
    const task = await Task.findOneAndDelete({ uuid: req.params.uuid });
    if (!task) {
      console.log('Task not found:', req.params.uuid);
      res.status(404).json({ message: 'Task not found' });
    } else {
      console.log('Task deleted:', task);
      res.send(task);
    }
  } catch (error) {
    console.error('Error deleting task:', error);
    res.status(500).json({ message: 'Server error', error });
  }
};