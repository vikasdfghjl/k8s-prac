import express from 'express';
const {registerUser, loginUser} = require('../controllers/usercontroller');

const router = express.Router();
// /api
router.post('/register', registerUser);
router.post('/login', loginUser);

export default router;