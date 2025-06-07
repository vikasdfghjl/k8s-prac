# Backend

> Node Express Typescript

```bash
npm run dev
```

## Create a secrets.env in the root directory ( in the same directory of docker-compose.yaml)

## secrets.env example

```env
MONGO_URI=mongodb://username:password@mongodb:27017/totodo?authSource=admin
JWT_SECRET=your_jwt_secret
PORT=5000
```

## .env example for mongo-user and password

```env
MONGO_INITDB_ROOT_USERNAME=username
MONGO_INITDB_ROOT_PASSWORD=password
```

## DOCKER COMMANDS

```bash
docker-compose up  # to start the docker containers
docker-compose up -d # to start the docker containers in detach mode

docker-compose down # to stop the docker containers 
docker-compose down -v # to stop the docker containers also remove volumes


# Check Docker Logs
docker logs frontend
docker logs backend
docker logs mongodb

```
