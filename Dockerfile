FROM golang:1.13.7-stretch

ENV OPA_VERSION=v0.17.1

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

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
