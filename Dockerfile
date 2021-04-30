FROM ubuntu:20.04

# requirements
RUN apt-get update && apt-get install -y \
  curl \
  openssl \
  && rm -rf /var/lib/apt/lists/*

# default environment
ENV MODE=backup
ENV BACKUP_SRC=/volumes-src/
ENV BACKUP_FILE_NAME=backup-volumes.tar.gz.enc
ENV BACKUP_FILE=/data/${BACKUP_FILE_NAME}
ENV BACKUP_DEST=/volumes-dest/
ENV KEY=""
ENV OPENSSL_PARAM="-aes-256-cbc -pbkdf2 -iter 100000"
ENV UPLOAD_URL="https://transfer.sh/${BACKUP_FILE_NAME}"
ENV DOWNLOAD_URL=""

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]