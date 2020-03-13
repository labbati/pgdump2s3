#!/bin/sh

set -e

export PGHOST=${PGHOST:-localhost}
export PGPORT=${PGPORT:-5432}
export PGDATABASE=${PGDATABASE:-test}
export PGUSER=${PGUSER:-test}
export PGPASSWORD=${PGPASSWORD:-test}

BACKUP_FILENAME=backup-$(date '+%FT%H-%M-%S%Z')

pg_dump ${PGDUMP_OPTIONS} > ${BACKUP_FILENAME}

echo "Succesfully dumped backup to file: ${BACKUP_FILENAME}"

echo "Copying file to S3 bucket '${S3_BUCKET}'"
aws s3 cp ${BACKUP_FILENAME} "s3://${S3_BUCKET}/"
