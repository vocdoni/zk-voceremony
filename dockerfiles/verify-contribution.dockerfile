FROM node

WORKDIR /app

COPY . /app

RUN npm config set update-notifier false && \
    npm install -g snarkjs

CMD [ "bash", "/app/scripts/verify-contribution.sh" ]