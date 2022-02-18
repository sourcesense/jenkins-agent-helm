FROM alpine:3.15.0 as alpine

FROM alpine as curl

WORKDIR /

RUN apk add curl

FROM curl as downloader

FROM downloader as helm-downloader

ARG helm_version="v3.8.0"
ARG OS=${TARGETOS:-linux}
ARG ARCH=${TARGETARCH:-amd64}

RUN curl -LO "https://get.helm.sh/helm-$helm_version-$OS-$ARCH.tar.gz"

RUN tar xvzf "helm-$helm_version-$OS-$ARCH.tar.gz"

RUN mv $OS-$ARCH/helm /usr/local/bin/helm

RUN chmod 0755 /usr/local/bin/helm

FROM downloader as yq-downloader

ARG OS=${TARGETOS:-linux}
ARG ARCH=${TARGETARCH:-amd64}
ARG YQ_VERSION="v4.20.1"
ARG YQ_BINARY="yq_${OS}_$ARCH"
RUN curl "https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/$YQ_BINARY" -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

FROM downloader as jq-downloader

ARG OS_ARCH=${TARGETOS_ARCH:-linux64}
ARG JQ_VERSION="1.6"
ARG JQ_BINARY="jq_${OS_ARCH}"
RUN curl "https://github.com/stedolan/jq/releases/download/jq-$JQ_VERSION/$JQ_BINARY" -o /usr/local/bin/jq && \
    chmod +x /usr/local/bin/jq


FROM alpine

RUN apk add git xmlstarlet bash

WORKDIR /app

COPY dep-bootstrap.sh .
RUN chmod +x ./dep-bootstrap.sh

RUN adduser -u 1000 -s /bin/bash -D jenkins
RUN mkdir -p /home/jenkins
RUN chown 1000:1000 /home/jenkins
ENV JENKINS_USER=jenkins

COPY --from=yq-downloader --chown=1000:1000 /usr/local/bin/yq /usr/local/bin/yq
COPY --from=helm-downloader --chown=1000:1000 /usr/local/bin/helm /usr/local/bin/helm
COPY --from=jq-downloader --chown=1000:1000 /usr/local/bin/jq /usr/local/bin/jq

USER 1000

RUN ./dep-bootstrap.sh 0.5.1 install
