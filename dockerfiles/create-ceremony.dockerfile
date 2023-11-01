FROM node

RUN apt update && apt install -y -q build-essential curl

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

RUN mkdir -p /temp && cd /temp && \
    git clone https://github.com/iden3/circom.git && \
    cd circom && \
    cargo build --release && \
    cargo install --path circom && \
    npm config set update-notifier false && \
    npm install -g snarkjs circomlib

WORKDIR /app

CMD [ "bash", "./scripts/create-ceremony.sh" ]