FROM node:12-alpine

COPY ./app ./app

WORKDIR /app/client
RUN npm install
RUN BUILD_PATH=/app/server/public node ./scripts/build.js

WORKDIR /app/server/src
RUN npm install

CMD PORT=3000 MONGODB_URL=mongodb://127.17.0.1:27017/todo-app JWT_SECRET=myjwtsecret node index.js
