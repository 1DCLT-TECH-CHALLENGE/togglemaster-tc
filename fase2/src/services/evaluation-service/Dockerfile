FROM golang:1.25 AS builder

WORKDIR /app

COPY go.mod ./
COPY go.sum* ./

RUN go mod download || true

COPY . .

RUN go build -o service .

FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/service /app/service

EXPOSE 8000

CMD ["/app/service"]
