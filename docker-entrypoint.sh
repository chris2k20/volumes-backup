#!/bin/bash

# check required parameters
if [ -z "$KEY" ]; then echo -e "ERROR: Missing Env-Variable \$KEY!" ; exit 1; fi
if [ "$MODE" != 'backup' ] && [ "$MODE" != 'restore' ] ; then echo -e "ERROR: Missing Env-Variable \$MODE! \n set \$MODE=backup to backup for files or \MODE=restore to restore your volumes" ; exit 1; fi

# Run Script
if [ "$MODE" = 'backup' ]; then
    echo -e "Starting backup mode.."
    # test
    if [ ! -d "${BACKUP_SRC:-/volumes-src/}" ]; then echo -e "ERROR: $BACKUP_SRC does not exist inside the container!\n Please set another BACKUP_SRC=/myfolder/ folder or mount a folder under the default $BACKUP_SRC into the container"; exit 1; fi

    cd ${BACKUP_SRC:-/volumes-src/} && \
    tar czf - . | openssl enc -e ${OPENSSL_PARAM:--aes-256-cbc} -out ${BACKUP_FILE:-/data/backup-volumes.tar.gz.enc} -pass env:KEY

    # upload file
    if [ "$UPLOAD_URL" != '' ]; then
        curl --upload-file ${BACKUP_FILE:-/data/backup-volumes.tar.gz.enc} ${UPLOAD_URL} && echo -e "\nFile uploaded! Please copy like above."
    fi
fi

if [ "$MODE" = 'restore' ]; then
    echo -e "Starting restore mode.."
    # test
    if [ ! -d "${BACKUP_DEST:-/volumes-dest/}" ]; then echo -e "ERROR: $BACKUP_DEST does not exist inside the container! \n Please set another BACKUP_DEST=/myfolder/ folder or mount a folder under the default $BACKUP_DEST into the container"; exit 1; fi

    # download file
    if [ "$DOWNLOAD_URL" != '' ]; then
        curl --output ${BACKUP_FILE:-/data/backup-volumes.tar.gz.enc} ${DOWNLOAD_URL} && echo -e "File downloaded!"
    fi
    openssl enc -d ${OPENSSL_PARAM:--aes-256-cbc} -in ${BACKUP_FILE:-/data/backup-volumes.tar.gz.enc} -pass env:KEY | tar zxf - --directory ${BACKUP_DEST:-/volumes-dest/}
fi