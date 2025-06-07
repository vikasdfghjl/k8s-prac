import { Schema, model } from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const taskSchema = new Schema({
  task: { type: String, required: true },
  description: { type: String },
  uuid: { type: String, default: uuidv4 },
  createdAt: { type: Date, default: Date.now },
  status: { type: String, default: 'pending' },
  completedAt: { type: Date }
  
});

export const Task = model('Task', taskSchema);