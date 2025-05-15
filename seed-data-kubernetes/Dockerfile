FROM python:3.9-slim AS python-builder

WORKDIR /app

COPY . .

RUN python make-data.py

FROM alpine:latest

RUN apk --no-cache add apache2-utils

COPY --from=python-builder /app/generate-votes.sh /app/
COPY --from=python-builder /app/posta /app/
COPY --from=python-builder /app/postb /app/

RUN chmod +x /app/generate-votes.sh

WORKDIR /app

CMD ["./generate-votes.sh"]
