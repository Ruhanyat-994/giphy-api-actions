FROM alpine:3.10

RUN apk update && \
    apk add --no-cache curl jq

    # This is the entrypoint script
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]