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
ENV LOGGLY_TOKEN 638bd2ef-acdf-497c-ba6a-2612878c5b4b
ENV TICKET_MASTER_KEY KMv583fPo0rXACykwKJDxPtEvSQWvwUQ
ENV AWS_ACCESS_KEY_ID AKIA34XNLPJYGEDLZAXG
ENV AWS_SECRET_ACCESS_KEY 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

# Check results
RUN env && pwd && find .

# Start the application
CMD ["./main"]

