ARG BUILD_FROM
FROM $BUILD_FROM

RUN apt-get update
RUN apt-get install -y \
        tzdata \
        bash \
        mariadb-client \
        gzip \
        openssl \
        curl
RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/*

COPY ["run.sh", "backup.sh", "/delete.sh", "/"]
RUN chmod 755 /run.sh /backup.sh /delete.sh && \
    touch /mysql_backup.log && \
    chmod 666 /mysql_backup.log

CMD [ "/run.sh" ]

LABEL org.opencontainers.image.source https://github.com/PrimusNZ/hassio-addons