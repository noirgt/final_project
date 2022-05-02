FROM alpine:3.9

ENV PYTHONUNBUFFERED=1
ENV PYCURL_SSL_LIBRARY=openssl
ENV MONGO=crawler_ui_db
ENV MONGO_PORT=27017

WORKDIR /crawler-ui
COPY ui .
COPY requirements.txt .

RUN apk add --no-cache libcurl
RUN apk --update add python3 curl-dev \
    && apk add --update --no-cache --virtual \
    .build-dependencies py3-pip python3-dev build-base \
    && pip3 install -r requirements.txt \
    && apk del .build-dependencies \
    && rm -rf /var/cache/apk/*

RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

CMD ["sh", "-c", "FLASK_APP=ui.py gunicorn ui:app -b 0.0.0.0"]
