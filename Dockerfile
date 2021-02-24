FROM ubuntu:focal

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64 && \
    add-apt-repository ppa:rmescandon/yq

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl && \
    curl https://baltocdn.com/helm/signing.asc | apt-key add - && \
    apt-get install apt-transport-https --yes && \
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    helm \
    jq \
    xmlstarlet \
    yq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY dep-bootstrap.sh .
RUN chmod +x ./dep-bootstrap.sh

RUN useradd -u 1000 -s /bin/bash jenkins
RUN mkdir -p /home/jenkins
RUN chown 1000:1000 /home/jenkins
ENV JENKINS_USER=jenkins

USER 1000

RUN ./dep-bootstrap.sh 0.4.1 install

