FROM node:22.9.0-alpine

RUN mkdir /azure-ci-cd

RUN chown -R node:node /azure-ci-cd

WORKDIR /azure-ci-cd

USER node

COPY --chown=node:node package.json /azure-ci-cd
COPY --chown=node:node package-lock.json /azure-ci-cd

RUN npm install

COPY --chown=node:node . .

EXPOSE 3000

CMD ["npx", "ts-node", "src/index.ts"]