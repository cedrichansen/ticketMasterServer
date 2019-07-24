## build in /Users/cedrichansen/Programs/go/src/chansen-ticket_master_grabber
## use command (to build): docker build -t chansen-ticket_master_grabber:1.0.0 .
## and command (to run): docker run -d chansen-ticket_master_grabber:1.0.0

# Start the Go app build
FROM golang:latest AS build

# Copy source
WORKDIR /go/src/chansen-ticket_master_grabber
COPY . .

# Get required modules (assumes packages have been added to ./vendor)
RUN go get -d -v ./...

# Build a statically-linked Go binary for Linux
RUN CGO_ENABLED=0 GOOS=linux go build -a -o main .

# New build phase -- create binary-only image
FROM alpine:latest

# Add support for HTTPS and time zones
RUN apk update && \
    apk upgrade

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*

WORKDIR /root/

# Copy files from previous build container
COPY --from=build /go/src/chansen-ticket_master_grabber/main ./

# Add environment variables
ENV LOGGLY_TOKEN <KEY>
ENV TICKET_MASTER_KEY <KEY>
ENV AWS_ACCESS_KEY_ID <KEY>
ENV AWS_SECRET_ACCESS_KEY <KEY>

# Check results
RUN env && pwd && find .

# Start the application
CMD ["./main"]

