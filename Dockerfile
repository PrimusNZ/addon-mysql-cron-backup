FROM alpine:3.18.2
LABEL maintainer "Fco. Javier Delgado del Hoyo <frandelhoyo@gmail.com>"

RUN apk add --update \
        tzdata \
        bash \
        mysql-client \
        gzip \
        openssl \
        curl \
        mariadb-connector-c && \
    rm -rf /var/cache/apk/*

RUN curl -J -L -o /tmp/bashio.tar.gz \
        "https://github.com/hassio-addons/bashio/archive/v0.7.1.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf \
        /tmp/bashio.tar.gz \
        --strip 1 -C /tmp/bashio \
    \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -fr /tmp/* 

COPY ["run.sh", "backup.sh", "/delete.sh", "/"]
RUN mkdir /backup && \
    chmod 777 /backup && \ 
    chmod 755 /run.sh /backup.sh /delete.sh && \
    touch /mysql_backup.log && \
    chmod 666 /mysql_backup.log

CMD [ "/run.sh" ]

LABEL org.opencontainers.image.source https://github.com/PrimusNZ/hassio-addons