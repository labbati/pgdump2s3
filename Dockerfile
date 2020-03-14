FROM alpine:3.11

RUN apk add --no-cache \
    python \
    curl \
    postgresql \
    unzip

# Installing awscli
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
    && unzip awscli-bundle.zip \
    && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
    && rm -rf awscli-bundle \
    && rm -rf awscli-bundle.zip

WORKDIR /app
ADD run.sh /app/run.sh
RUN chmod +x /app/run.sh

CMD [ "/app/run.sh" ]
