# Docker-Image: Universal volumes-backup

Purpose: **Migrate/Backup Container-Volumes or Folders locally or to other Hosts (easy but safe)!**

This universal container will encrypt the backup-file and upload it to [transfer.sh](https://transfer.sh/) (see Environment-customize). Enables Migration to another platform (eg. from Docker to Kubernetes).

No magic, very simple: This Image creates a tar-Archive from a folder (your volumes), saves it encrypted and uploads it, so that only you (and you alone) can access it everywhere.
Then the other way around (`MODE=restore`): download file (eg. `DOWNLOAD_URL=https://transfer.sh/U6TIL/backup-volumes.tar.gz.enc`), decrypt it and unzip it.

## General Usage

- Set your personal `KEY`, so that the backup-file can be safely AES-encrypted
- Different Folders for backup- and restore-mode to make sure the program does not overwrite the backup-data:
  - backup-mode: Mount your source folders into the container (ReadOnly): under `/volumes-backup/` (or customize `BACKUP_FOLDER=/volumes-backup/`)
  - restore-mode: Mount your destination folders into the container: under `/volumes-restore/` (or customize `RESTORE_FOLDER=/volumes-restore/`)

Important: **Mount the right folders in the right container-path in backup- and restore-mode!** (any name, here `volume1-myfiles` and `volume2-otherfolder`)

## Example:

### Backup-Mode

Part 1: The backup-mode to get a encrypted backup-file from the local folders `/home/user/myfolder/` and `/opt/otherfolder/`:

```bash
docker run -it --rm \
  -e "MODE=backup" \
  -e "KEY=MY_S3CReT_KeY" \
  -v "/home/user/myfolder/:/volumes-backup/volume1-myfiles:ro" \
  -v "/opt/otherfolder/:/volumes-backup/volume2-otherfolder:ro" \
  --mount type=tmpfs,destination=/data \
  user2k20/volumes-backup
```
The container **returns the unique url to the file**

### Restore-Mode

Part 2: Restore backup-file to the local folders `/home/user/myfolder/` and `/opt/otherfolder/`:

```bash
docker run -it --rm \
  -e "MODE=restore" \
  -e "KEY=MY_S3CReT_KeY" \
  -e "DOWNLOAD_URL=https://transfer.sh/YOURURL/backup-volumes.tar.gz.enc"
  -v "/home/user/myfolder/:/volumes-restore/volume1-myfiles" \
  -v "/opt/otherfolder/:/volumes-restore/volume2-otherfolder" \
  --mount type=tmpfs,destination=/data \
  user2k20/volumes-backup
```

To backup **whole docker volumes**: replace the absolute path from the example above `/home/user/myfolder/` with the name of the volume `myvolume1` (Docker Like)

```bash
  -v "myvolume1:/volumes-restore/volume1-myfiles" \
```
## Offline Usage

NO ONLINE UPLOAD: The encrypted backup file will be saved to `/data/`, so create a volume under this path. If you set `UPLOAD_URL=` to zero, nothing gets uploaded.

```bash
# backup
docker run -it --rm \
  -e "MODE=backup" \
  -e "UPLOAD_URL=" \
  -e "KEY=MY_S3CReT_KeY" \
  -v "myvolume1:/volumes-backup/volume1-myvolume1:ro" \
  -v "secondvolume:/volumes-backup/volume2-secondvolume:ro" \
  -v "data:/data/" \
  user2k20/volumes-backup

# restore
docker run -it --rm \
  -e "MODE=restore" \
  -e "DOWNLOAD_URL=" \
  -e "KEY=MY_S3CReT_KeY" \
  -v "myvolume1:/volumes-restore/volume1-myvolume1" \
  -v "secondvolume:/volumes-restore/volume2-secondvolume" \
  -v "data:/data/" \
  user2k20/volumes-backup
```

## Kubernetes Job

An example manifest, which will run once as job. It will restore the backup to the volume claims (here mysql and wordpress volumes). Replace all environment variables and the volume parts:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: volumes-backup
spec:
  template:
    spec:
      containers:
      - name: volumes-backup
        image: user2k20/volumes-backup
        env:
          - name: MODE
            value: restore
          - name: KEY
            value: MY_S3CReT_KeY
          - name: DOWNLOAD_URL
            value: https://transfer.sh/YOURURL/backup-volumes.tar.gz.enc
        volumeMounts:
          - mountPath: /data
            name: data-volume
          - mountPath: /volumes-restore/volume1-wordpress
            name: wordpress-claim0
          - mountPath: /volumes-restore/volume1-mysql
            name: mysql-claim0
      restartPolicy: Never
      volumes:
        - name: data-volume
          emptyDir: {}
        - name: wordpress-claim0
          persistentVolumeClaim:
            claimName: wordpress-claim0
        - name: mysql-claim0
          persistentVolumeClaim:
            claimName: mysql-claim0
  backoffLimit: 0
status: {}
```

## Environment Variables

**`MODE`**

This variable is mandatory and specifies the modus `backup` or `restore`

**`BACKUP_FOLDER`**

Sets the folder that will be backuped. Default: mount all your volumes under `/volumes-backup/`

**`BACKUP_FILE_NAME`**

The default backup name: `backup-volumes.tar.gz.enc`

**`BACKUP_FILE`**

Full path and filename. Default is `/data/${BACKUP_FILE_NAME}`


**`RESTORE_FOLDER`**

Where will the Backup be restored. Default is `/volumes-restore/`

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

## No guarantee and no support

If you find any mistakes or have an improvement, please leave a comment. 😋
