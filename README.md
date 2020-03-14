# pgdump2s3

![Docker Build Status](https://img.shields.io/docker/build/labbati/pgdump2s3)

pgdump2s3 is a docker image that let you:

1. backup a postgresql database and upload the backup to a S3 bucket,
2. optionally verify that the backup can be restored,
3. optionally verify that a specific table exists inside the restored database.

Examples of how to run this image from command line, in a docker compose file and in k8s are provided.

## Configuration

pgdump2s3 uses environment variables to configure its behavior.

`PGHOST` [Default: `localhost`]: postgresql host.

`PGPORT` [Default: `5432`]: postgresql port.

`PGDATABASE` [Default: `test`]: postgresql database name.

`PGUSER` [Default: `test`]: postgresql username.

`PGPASSWORD` [Default: `test`]: postgresql password.

`PGDUMP_OPTIONS` [Default: `-Fc -b`]: command line options passed to `pg_dump`. The default value `-Fc -b`, lets you include blobs and uses the `pg_dump` custom compression format.

`PGRESTORE_OPTIONS` [Default: ``]: command line options passed to `pg_restore`.

`VERIFY_BACKUP` [Default: `skip`]: whether the tool should verify the backup file. By default the backup file is not verified. If you want to run verification set value to `verify`. The restored database is dropped automatically after verification is completed. **WARNING**: restoring a backfile will take both memory and space on the postgresql server. Please use with awareness.

`VERIFY_TABLE_NAME`: [Default: ``]: If provided, then the tool will not only restore the backup file, it will also check for the existence of the provided table name.

`VERIFY_SCHEMA_NAME` [Default: `public`]: The schema name for table existence verification.

`AWS_ACCESS_KEY_ID` [Required]: the aws access key.

`AWS_SECRET_ACCESS_KEY` [Required]: the aws access secret.

`AWS_S3_BUCKET` [Required]: the aws bucket name.

## Usage in docker

Example: using psdump2s3 to backup a database from a server in the current machine.

```
docker run --rm \
    --net=host \
    -e PGHOST=localhost \
    -e PGDATABASE=test \
    -e PGUSER=test \
    -e PGPASSWORD=test \
    -e AWS_ACCESS_KEY_ID=<your aws access key> \
    -e AWS_SECRET_ACCESS_KEY=<your aws access secret> \
    -e AWS_S3_BUCKET=<bucket name> \
    -e VERIFY_BACKUP=verify \
    -e VERIFY_TABLE_NAME=<a table that should exists> \
    labbati/pgdump2s3
```

## Usage in docker compose

```
...
services:

  db:
    ...

  backup:
    image: labbati/pgdump2s3
    environment:
      PGHOST: db
      PGDATABASE: test
      PGUSER: test
      PGPASSWORD: test
      AWS_ACCESS_KEY_ID: <your aws access key>
      AWS_SECRET_ACCESS_KEY: <your aws access secret>
      AWS_S3_BUCKET: <bucket name>
      VERIFY_BACKUP: verify
      VERIFY_TABLE_NAME: <a table that should exists>
```

Then you can run it as

```
docker-compose run --rm backup
```

## License: MIT

MIT License

Copyright (c) 2020 Luca Abbati

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
