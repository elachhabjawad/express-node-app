FROM node:14 as base

FROM node:14 as dev

WORKDIR /app

COPY package.json .

RUN npm install 

COPY  . .
EXPOSE 4000

CMD [ "npm" ,"dev" ]


FROM node:14 as prod

WORKDIR /app

COPY package.json .

RUN npm install 

COPY  . .
EXPOSE 4000

CMD [ "npm" ,"start" ]