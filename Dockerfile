FROM golang:1.18-bullseye AS builder

ADD . /workspace
WORKDIR /workspace
RUN make build

FROM golang:1.18-bullseye
COPY --from=builder /workspace/build/ag0 /usr/local/bin/ag0

RUN apt-get update && apt-get install jq -y
ENTRYPOINT ["/usr/local/bin/ag0"]