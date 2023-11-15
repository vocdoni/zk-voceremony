### image to contribute, verify, finish ceremonies
FROM node AS zk-voceremony

WORKDIR /app

RUN npm config set update-notifier false && \
    npm install -g snarkjs

RUN apt update \
    && apt install --no-install-recommends -y curl \
    && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
    && apt install --no-install-recommends -y git-lfs \
    && git lfs install \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install --no-install-recommends -y gh \
	&& apt autoremove -y \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./scripts/* /bin/

CMD [ "contribute" ]

### image to create ceremonies
FROM node AS zk-voceremony-create

WORKDIR /app

RUN apt update && apt install --no-install-recommends -y -q build-essential curl

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

RUN mkdir -p /temp && cd /temp && \
    git clone https://github.com/iden3/circom.git && \
    cd circom && \
    cargo build --release && \
    cargo install --path circom && \
    npm config set update-notifier false && \
    npm install -g snarkjs circomlib

COPY ./scripts/* /bin/

CMD [ "create", "-y" ]
