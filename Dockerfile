FROM alpine:3.11

RUN apk add --no-cache postgresql-client

WORKDIR /app
ADD run.sh /app/run.sh
RUN chmod +x /app/run.sh

CMD [ "/app/run.sh" ]
