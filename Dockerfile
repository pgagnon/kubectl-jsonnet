FROM alpine:latest AS builder

RUN apk -U add build-base git

WORKDIR /opt

RUN git clone https://github.com/google/jsonnet.git

COPY . /opt/jsonnet

RUN cd jsonnet && \
    make

FROM alpine:3.7

RUN apk add --no-cache libstdc++ 

COPY --from=builder /opt/jsonnet/jsonnet /usr/local/bin
COPY --from=builder /opt/jsonnet/jsonnetfmt /usr/local/bin

ARG VERSION=1.13.11
ENV KUBE_VERSION=$VERSION

RUN apk add --update ca-certificates \
 && apk add --update -t deps curl \
 && apk add --update bash \
 && apk add --update git \
 && git clone https://github.com/ksonnet/ksonnet-lib.git \
 && curl -L https://dl.k8s.io/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/jsonnet /usr/local/bin/jsonnetfmt \
 && apk del --purge deps \
 && rm /var/cache/apk/*

WORKDIR /root
ENTRYPOINT ["kubectl"]
CMD ["help"]
