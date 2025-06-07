# ToToDo Backend

This is the backend for the ToToDo application, built with Node.js, Express, TypeScript, and MongoDB.

## Features
- User registration and login with JWT authentication
- Task management (CRUD)
- MongoDB integration
- Prometheus metrics at `/metrics`

## Getting Started

### 1. Install dependencies
```powershell
cd backend
npm install
```

### 2. Set up environment variables
Create a `.env` file or use `secrets.env` with the following:
```
MONGO_URI=mongodb://<username>:<password>@<host>:<port>/<database>?authSource=admin
JWT_SECRET=your_jwt_secret
```

### 3. Run the backend
```powershell
npm start
```

The server will start on port 5000 by default.

---

## API Endpoints

| Method | Endpoint            | Description                | Auth Required |
|--------|---------------------|----------------------------|---------------|
| POST   | /api/users/register | Register a new user        | No            |
| POST   | /api/users/login    | Login and get JWT token    | No            |
| GET    | /api/tasks          | Get all tasks              | Yes (No if auth disabled) |
| POST   | /api/tasks          | Create a new task          | Yes (No if auth disabled) |
| PUT    | /api/tasks/:id      | Update a task by ID        | Yes (No if auth disabled) |
| DELETE | /api/tasks/:id      | Delete a task by ID        | Yes (No if auth disabled) |
| GET    | /metrics            | Prometheus metrics         | No            |

---

## Using Endpoints in Postman

1. **Register a user**
   - Method: POST
   - URL: `http://localhost:5000/api/users/register`
   - Body (JSON):
     ```json
     {
       "username": "yourname",
       "password": "yourpassword"
     }
     ```

2. **Login**
   - Method: POST
   - URL: `http://localhost:5000/api/users/login`
   - Body (JSON):
     ```json
     {
       "username": "yourname",
       "password": "yourpassword"
     }
     ```
   - Response will include a JWT token.

3. **Authenticated requests (tasks)**
   - For all `/api/tasks` endpoints, add an `Authorization` header:
     ```
     Authorization: Bearer <your_jwt_token>
     ```

4. **Example: Create a Task**
   - Method: POST
   - URL: `http://localhost:5000/api/tasks`
   - Headers:
     - `Authorization: Bearer <your_jwt_token>`
   - Body (JSON):
     ```json
     {
       "title": "My Task",
       "description": "Task details"
     }
     ```

5. **Get Prometheus Metrics**
   - Method: GET
   - URL: `http://localhost:5000/metrics`

---

## Notes
- Replace `localhost:5000` with your actual backend URL if running in Docker, Kubernetes, or Minikube.
- All protected endpoints require a valid JWT token in the `Authorization` header (unless authentication is temporarily disabled).
- **Note:** If you have disabled authentication in `index.ts` (by removing the `protect` middleware), all `/api/tasks` endpoints are accessible without a JWT token for development/testing purposes.
