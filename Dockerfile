### we forked gh to reduce the auth permissions requested
FROM golang:1.21 AS gh

WORKDIR /src

RUN wget https://github.com/vocdoni/gh-cli/archive/refs/tags/v2.39.3-vocdoni.tar.gz -O - | tar -xz --strip-components=1

RUN --mount=type=cache,sharing=locked,id=gomod,target=/go/pkg/mod/cache \
	go mod download -x
RUN --mount=type=cache,sharing=locked,id=gomod,target=/go/pkg/mod/cache \
	--mount=type=cache,sharing=locked,id=goroot,target=/root/.cache/go-build \
	go build -ldflags="-s -w -X github.com/cli/cli/v2/internal/build.Version=v2.39.3-vocdoni -X github.com/cli/cli/v2/internal/build.Date=$(date --iso-8601)" \
       -o=/bin ./cmd/gh

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
    && apt install --no-install-recommends -y jq \
	&& apt autoremove -y \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./scripts/* /bin/

COPY --from=gh /bin/gh /bin/gh

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
