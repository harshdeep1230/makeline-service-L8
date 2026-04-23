# Use an official Golang runtime as a parent image
FROM golang:1.22.5-alpine AS builder

# Install git (required for fetching some Go dependencies)
RUN apk add --no-cache git

WORKDIR /app

# Copy go.mod and go.sum files first to leverage Docker cache
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Go app
ARG APP_VERSION=0.1.0
RUN go build -ldflags "-X main.version=$APP_VERSION" -o main .

# Run the app on alpine
FROM alpine:latest AS runner
WORKDIR /root/

ARG APP_VERSION=0.1.0
COPY --from=builder /app/main .

# Expose port 3001
EXPOSE 3001
ENV APP_VERSION=$APP_VERSION

CMD ["./main"]
