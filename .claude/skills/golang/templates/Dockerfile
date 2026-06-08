# Multi-stage Dockerfile para serviço Go production-ready
# Fonte: https://docs.docker.com/build/building/multi-stage/

# Build stage
FROM golang:1.24 AS build
WORKDIR /src

# Cache go modules
COPY go.mod go.sum ./
RUN go mod download

# Build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /app ./cmd/server

# Runtime stage (distroless — sem shell, sem package manager)
FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=build /app /app

USER nonroot:nonroot
EXPOSE 8080

ENTRYPOINT ["/app"]
