# Stage 1: Build
FROM golang:1.22.5-alpine AS builder

# Install git - required for fetching Go modules
RUN apk add --no-cache git

WORKDIR /app

# Copy go.mod and go.sum first to leverage Docker cache
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Go app
ARG APP_VERSION=0.1.0
RUN go build -ldflags "-X main.version=$APP_VERSION" -o main .

# Stage 2: Runner
FROM alpine:latest AS runner

WORKDIR /root/

ARG APP_VERSION=0.1.0
COPY --from=builder /app/main .

EXPOSE 3001
ENV APP_VERSION=$APP_VERSION

CMD ["./main"]