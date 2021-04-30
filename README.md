# Docker-Image: volume-backup

Purpose: **Easy but safe way to migrate/backup Volumes or Folders locally or to other Hosts**

No magic: This Image creates a tar-Archive from a folder, saves it encrypted and upload it, so that only you (and you alone) can access it everywhere.
Then the other way around (`MODE=restore`): download file (eg. `DOWNLOAD_URL=https://transfer.sh/U6TIL/backup-volumes.tar.gz.enc`), decrypt it and unzip it.


##  Migration

Backup all your volumes with this container. Encrypted backup-file will be uploaded to [transfer.sh](https://transfer.sh/) (disable or reset with env-variable `UPLOAD_URL=""`, see Environment-Section below).

- Mount your source folders into the container (ReadOnly): under `/volume-src/` (or customize `BACKUP_SRC=/volumes-src/`)
- Mount your destination folders into the container: under `/volume-dest/` (or customize `BACKUP_DEST=/volumes-dest/`)

Important: **Mount the right folders in the right container-path in backup- and restore-mode!**

## Example: Local Folders

### Backup-Mode - Folders

local folders `/home/user/myfolder/` and `/opt/otherfolder/`:

```bash
docker run -it --rm \
  -e "MODE=backup" \
  -e "KEY=MY_S3CReT_KeY" \
  -v "/home/user/myfolder/:/volumes-src/volume1-myfiles:ro" \
  -v "/opt/otherfolder/:/volumes-src/volume2-otherfolder:ro" \
  --mount type=tmpfs,destination=/data \
  dockertransfervolume
```
The container **returns the unique url, to get the file**

### Restore-Mode - Folders

local folders `/home/user/myfolder/` and `/opt/otherfolder/`:

```bash
docker run -it --rm \
  -e "MODE=restore" \
  -e "KEY=MY_S3CReT_KeY" \
  -e "DOWNLOAD_URL=https://transfer.sh/YOURURL/backup-volumes.tar.gz.enc"
  -v "/home/user/myfolder/:/volumes-dest/volume1-myfiles" \
  -v "/opt/otherfolder/:/volumes-dest/volume2-otherfolder" \
  --mount type=tmpfs,destination=/data \
  dockertransfervolume
```

## Example: Docker Volumes

### Backup-Mode - Volumes

local docker volumes `myvolume1` and `secondvolume`:

```bash
docker run -it --rm \
  -e "MODE=backup" \
  -e "KEY=MY_S3CReT_KeY" \
  -v "myvolume1:/volumes-src/volume1-myvolume1:ro" \
  -v "secondvolume:/volumes-src/volume2-secondvolume:ro" \
  --mount type=tmpfs,destination=/data \
  dockertransfervolume
```
The container **returns the unique url, to get the file**

### Restore-Mode - Volumes

local docker volumes `myvolume1` and `secondvolume`:

```bash
docker run -it --rm \
  -e "MODE=restore" \
  -e "DOWNLOAD_URL=https://transfer.sh/YOURURL/backup-volumes.tar.gz.enc" \
  -e "KEY=MY_S3CReT_KeY" \
  -v "myvolume1:/volumes-dest/volume1-myvolume1" \
  -v "secondvolume:/volumes-dest/volume2-secondvolume" \
  --mount type=tmpfs,destination=/data \
  dockertransfervolume
```

## Offline Usage

NO ONLINE UPLOAD: The encrypted backup file will be saved to `/data/`, so create a volume under this path. If you set `UPLOAD_URL=` to zero, nothing gets uploaded.

```bash
# backup
docker run -it --rm \
  -e "MODE=backup" \
  -e "UPLOAD_URL=" \
  -e "KEY=MY_S3CReT_KeY" \
  -v "myvolume1:/volumes-src/volume1-myvolume1:ro" \
  -v "secondvolume:/volumes-src/volume2-secondvolume:ro" \
  -v "data:/data/" \
  dockertransfervolume

# restore
docker run -it --rm \
  -e "MODE=restore" \
  -e "DOWNLOAD_URL=" \
  -e "KEY=MY_S3CReT_KeY" \
  -v "myvolume1:/volumes-dest/volume1-myvolume1" \
  -v "secondvolume:/volumes-dest/volume2-secondvolume" \
  -v "data:/data/" \
  dockertransfervolume
```

## Environment Variables

**`MODE`**

This variable is mandatory and specifies the modus `backup` or `restore`

**`BACKUP_SRC`**

Sets the folder that will be backuped. Default: mount all your volumes under `/volumes-src/`

**`BACKUP_FILE_NAME`**

The default backup name: `backup-volumes.tar.gz.enc`

**`BACKUP_FILE`**

Full path and filename. Default is `/data/${BACKUP_FILE_NAME}`


**`BACKUP_DEST`**

Where will the Backup be restored. Default is `/volumes-dest/`

**`KEY`**

This variable is mandatory and specifies the encryption key.

**`OPENSSL_PARAM`**

Parameters that are used to decrypt/encrypt the backup file. Default: `-aes-256-cbc`

**`UPLOAD_URL`**

For the backup-mode: Sets the URL where the encrypted backups will be sent to. Default here is: `https://transfer.sh/${BACKUP_FILE_NAME}` (host your [own transfer.sh container](https://github.com/dutchcoders/transfer.sh) – *great work by these guys!*).

**`DOWNLOAD_URL`**

For the restore-mode. Sets the download url, where is the backup file is saved. NO default. You need to set this variable to the output-URL of the backup-mode.

## Contributions

Contributions are always welcome.