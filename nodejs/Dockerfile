FROM node:8

WORKDIR /opt/etherium

COPY package.json .

RUN npm install

COPY server.js .

ENTRYPOINT [ "node", "server.js" ]