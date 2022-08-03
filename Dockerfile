FROM golang:1.19-bullseye AS builder

ARG version_name=unknown
ENV VERSION=$version_name

ADD . /workspace
WORKDIR /workspace
RUN make build

FROM golang:1.19-bullseye
COPY --from=builder /workspace/build/ag0 /usr/local/bin/ag0

RUN apt-get update && apt-get install jq -y
ENTRYPOINT ["/usr/local/bin/ag0"]