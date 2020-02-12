FROM golang:1.13.7-stretch

ENV OPA_VERSION=v0.16.2

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        jq \
        vim \
    && rm -rf /var/lib/apt/lists/*

# Install open-policy-agent/opa
RUN mkdir -p /tmp/opa \
    && wget -O /tmp/opa/opa_linux_amd64 https://github.com/open-policy-agent/opa/releases/download/${OPA_VERSION}/opa_linux_amd64 \
    && mv /tmp/opa/opa_linux_amd64 /usr/local/bin/opa \
    && chmod +x /usr/local/bin/opa \
    && rm -rf /tmp/opa

## Install github-comment
RUN wget -O /tmp/github-comment.tar.gz https://github.com/b4b4r07/misc-1/releases/download/v0.1.3/github-comment-0.1.2-linux-amd64.tar.gz \
    && cd /tmp \
    && tar -zxvf /tmp/github-comment.tar.gz \
    && mv github-comment-linux-amd64/github-comment /usr/local/bin/github-comment \
    && rm /tmp/github-comment.tar.gz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
