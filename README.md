# 🐳 Docker Full Course Notes

## Core Concepts

| Term           | Description                                                             |
| -------------- | ----------------------------------------------------------------------- |
| **🐳 Docker**     | Platform to build, ship, and run apps in containers.                    |
| **📦 Container**  | Isolated environment to run your application.                           |
| **🖼️ Image**      | Read-only template used to create containers.                           |
| **🖥️ VM**         | Virtual Machine; emulates a full OS with more overhead than containers. |
| **📄 Dockerfile** | A script to define how a Docker image is built.                         |

---

## Basic Dockerfile

**📄 Dockerfile 👇**

```dockerfile
FROM node:14

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 4000

CMD ["npm", "run", "dev"]
```

---

## ⚙️ Docker Optimization

**📄 .dockerignore 👇**

```.dockerignore
/node_modules
Dockerfile
.env
package-lock.json
```

---

## 🔧 Docker Commands

**Build image**

`docker build -t express-node-app .`

**List images**

`docker image ls`

**Run container**

`docker run --name express-node-app-container -d -p 4000:4000 express-node-app`

**List running containers**

`docker ps`

**Remove container**

`docker rm express-node-app-container -f`

**Enter container shell**

`docker exec -it express-node-app-container bash`

**View container logs**

`docker logs express-node-app-container`

---

## 🔄 Hot Reload & Volumes

**Basic volume mount**

`docker run --name express-node-app-container  -v /Users/Imane/Desktop/jawad/express-node-app:/app  -d -p 4000:4000 express-node-app`

**Read-only mount**

`docker run --name express-node-app-container -v /Users/Imane/Desktop/jawad/express-node-app:/app:ro -d -p 4000:4000 express-node-app`

**Linux volume mount (read-only)**

`docker run --name express-node-app-container -v ${PWD}:/app:ro -d -p 4000:4000 express-node-app`

**Windows volume mount (read-only)**

`docker run --name express-node-app-container  -v %cd%:/app:ro -d -p 4000:4000 express-node-app`

**Volume mount with node_modules excluded**

`docker run --name express-node-app-container -v %cd%:/app -v /app/node_modules  -d -p 4000:4000 express-node-app`

**Mount only src folder read-only**

`docker run --name express-node-app-container  -v %cd%/src:/app/src:ro -d -p 4000:4000 express-node-app`

--
## Docker Compose Basic

**📄 docker-compose.yml 👇**
```docker-compose.yml
version: '3'
services:
  node-app:
    container_name: 'express-node-app-container'
    build: .
    volumes:
      - ./src:/app/src:ro
    ports:
      - '4000:4000'
```

### Run commands
```docker compose up```
```docker compose down```



----
## ⚙️ Environment Variables

### Solution 1 : Dockerfile

**📄 Dockerfile 👇**

```Dockerfile
FROM node:14

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

ENV PORT=4000

EXPOSE $PORT

CMD ["npm", "run", "dev"]
```
### Solution 2 : Run container with env vars
```docker run --name express-node-app-container -v %cd%/src:/app/src:ro --env PORT=4000 --env NODE_ENV=dev -d -p 4000:4000 express-node-app```

### Solution 3 : Using .env file
**📄 .env 👇**
Create .env file:
```.env
PORT=4000
NODE_ENV=development
```
```docker run --name express-node-app-container -v %cd%/src:/app/src:ro  --env-file ./.env  -d -p 4000:4000 express-node-app```

### Solution 3 : Docker Compose with Environment Variables
**📄 docker-compose.yml 👇**
```docker-compose.yml
version: '3'
services:
  node-app:
    container_name: 'express-node-app-container'
    build: .
    volumes:
      - ./src:/app/src:ro
    ports:
      - '4000:4000'
    environment:
      - PORT=4000
      - NODE_ENV=prod
    env_file:
      - ./.env
```
## Docker Environments (Dev, Prod)
### Solution 1 : 

**📄 docker-compose.prod.yml 👇**
```docker-compose.prod.yml
version: '3'
services:
  node-app:
    container_name: 'express-node-app-container'
    build: .
    ports:
      - '4000:4000'
    environment:
      - PORT=4000
      - NODE_ENV=prod
    env_file:
      - ./.env
```
**📄 docker-compose.dev.yml 👇**

```docker-compose.dev.yml
version: '3'
services:
  node-app:
    container_name: 'express-node-app-container'
    build: .
    volumes:
      - ./src:/app/src:ro
    ports:
      - '4000:4000'
    environment:
      - PORT=4000
      - NODE_ENV=dev
    env_file:
      - ./.env
```
**🖥️ Run commands**
```docker-compose -f docker-compose.dev.yml up -d```
```docker-compose -f docker-compose.prod.yml up -d```

---
### Solution 2 : Combined Docker Compose Files
**📄 docker-compose.yml 👇**
```docker-compose.yml
version: '3'
services:
  node-app:
    container_name: 'express-node-app-container'
    build: .
    ports:
      - '4000:4000'
    env_file:
      - ./.env
```
**📄 docker-compose.dev.yml 👇**
```docker-compose.dev.yml
version: '3'
services:
  node-app:
    volumes:
      - ./src:/app/src:ro
    environment:
      - NODE_ENV=dev
```

**📄 docker-compose.prod.yml 👇**
```docker-compose.prod.yml
version: '3'
services:
  node-app:
    environment:
      - NODE_ENV=prod
```
**🖥️ Run commands**
```docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d```
```docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build```


---

## Multi-Stage Dockerfile & Compose

**📄 Dockerfile 👇**
  
```Dockerfile
FROM node:14 as base

FROM node:14 as dev

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 4000

CMD ["npm", "run", "dev"]

FROM node:14 as prod

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

EXPOSE 4000

CMD ["npm", "start"]
```

**📄 docker-compose.dev.yml 👇**
```docker-compose.dev.yml
version: '3'
services:
  node-app:
    build:
      context: .
      target: dev
    volumes:
      - ./src:/app/src:ro
    environment:
      - NODE_ENV=dev
    command: npm run dev
```
**📄 docker-compose.prod.yml 👇**

```docker-compose.prod.yml
version: '3'
services:
  node-app:
    build:
      context: .
      target: prod
    environment:
      - NODE_ENV=prod
    command: npm run start
```