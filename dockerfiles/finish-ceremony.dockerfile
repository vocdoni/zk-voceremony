FROM node

RUN npm config set update-notifier false && \
    npm install -g snarkjs

WORKDIR /app

CMD [ "bash", "./scripts/finish-ceremony.sh" ]