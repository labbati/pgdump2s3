# pgdump2s3

![Docker Pulls](https://img.shields.io/docker/pulls/labbati/pgdump2s3)

pgdump2s3 is a docker image that lets you:

1. backup a postgresql database and upload the backup to a AWS S3 bucket,
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

`VERIFY_BACKUP` [Default: `skip`]: whether the tool should verify the backup file. By default the backup file is not verified. If you want to run verification set value to `verify`. The restored database is dropped automatically after verification is completed. **WARNING**: restoring a backup file requires both memory and space on the postgresql server. Please use with awareness.

`VERIFY_TABLE_NAME` [Default: ``]: If provided, then the tool will not only restore the backup file, it will also check for the existence of the provided table name.

`VERIFY_SCHEMA_NAME` [Default: `public`]: The schema name for table existence verification. Only used in conjunction with `VERIFY_TABLE_NAME`.

`AWS_ACCESS_KEY_ID` [Required]: the aws access key.

`AWS_SECRET_ACCESS_KEY` [Required]: the aws access secret.

`AWS_S3_BUCKET` [Required]: the aws bucket name.

`AWS_CLI_OPTIONS` [Default: ``]: Optional aws cli parameters for the `cp` command. E.g. use this to setup encryption. See a list of [valid values from cli docs](https://docs.aws.amazon.com/cli/latest/reference/s3/cp.html).

## Usage in docker

Example: using pgdump2s3 to backup a database from a server in the current machine.

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

## Usage in kubernetes

The following section assumes that a [k8s secret](https://kubernetes.io/docs/concepts/configuration/secret/) `aws-credentials` exists with keys `access-key` and `access-secret`.

You can create one with the following command:

```
kubectl create secret generic aws-credentials --from-literal=access-key=<aws access key> --from-literal=access-secret='<aws access secret>'
```

_Note_: you can avoid the command above to be kept in your shell history: see [`HISTORY_IGNORE` for zsh](http://zsh.sourceforge.net/Doc/Release/Parameters.html#Parameters-Used-By-The-Shell) and [`HISTIGNORE` for bash](https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html).

Define a [k8s job](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/) that looks like this:

```
# file: backup-job.yml

apiVersion: batch/v1
kind: Job
metadata:
  name: backup
spec:
  template:
    spec:
      containers:
        - name: backup
          image: labbati/pgdump2s3
          imagePullPolicy: Always
          env:
            - name: PGHOST
              value: <host>
            - name: PGDATABASE
              value: <database name>
            - name: PGUSER
              value: <user e.g. from a secret>
            - name: PGPASSWORD
              value: <password e.g. from a secret>
            - name: VERIFY_BACKUP
              value: verify
            - name: VERIFY_TABLE_NAME
              value: <a table you expect to be in the backup>
            - name: AWS_S3_BUCKET
              value: <your bucket name>
            - name: AWS_ACCESS_KEY_ID
              valueFrom:
                secretKeyRef:
                  name: aws-credentials
                  key: access-key
            - name: AWS_SECRET_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: aws-credentials
                  key: access-secret
      restartPolicy: Never
  backoffLimit: 1
```

Then apply it

```
kubectl apply -f backup-job.yml
```

Of course you can check logs

```
kubectl logs -f backup-<pod unique>
```

You can also transform the job above into a recurring job defining a k8s [`CronJob`](). As an example you can rewrite the
above job into the following, that will backup your database at 00:30 in the k8s cluster manager timezone every night.

```
# file: backup-cronjob.yml

apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: backup
spec:
  schedule: '30 0 * * *'
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: backup
              image: labbati/pgdump2s3
              imagePullPolicy: Always
              env:
                - name: PGHOST
                  value: <host>
                - name: PGDATABASE
                  value: <database name>
                - name: PGUSER
                  value: <user e.g. from a secret>
                - name: PGPASSWORD
                  value: <password e.g. from a secret>
                - name: VERIFY_BACKUP
                  value: verify
                - name: VERIFY_TABLE_NAME
                  value: <a table you expect to be in the backup>
                - name: AWS_S3_BUCKET
                  value: <your bucket name>
                - name: AWS_ACCESS_KEY_ID
                  valueFrom:
                    secretKeyRef:
                      name: aws-credentials
                      key: access-key
                - name: AWS_SECRET_ACCESS_KEY
                  valueFrom:
                    secretKeyRef:
                      name: aws-credentials
                      key: access-secret
          restartPolicy: Never
```

And then apply it

```
kubectl apply -f backup-cronjob.yaml
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
