FROM node:9.0.0-alpine

RUN mkdir -p /mom
WORKDIR /mom

COPY package.json package-lock.json ./
RUN npm install

COPY src ./src
COPY test ./test

ENTRYPOINT [ "/usr/local/bin/npm" ]
