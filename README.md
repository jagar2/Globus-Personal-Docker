# Globus-Personal-Docker

This repository contains a Dockerfile for building a Docker image that can be
used to run a Globus Connect Personal endpoint. The image is based on the
[globus/globus-connect-server](https://hub.docker.com/r/globus/globus-connect-server)
image, and adds a script that can be used to configure the server with a
personal endpoint.

## Build container

```sh
docker build --platform=linux/amd64 -t globus .
```

## Run container for setup

Adjust the host-side paths as appropriate, and make sure they exist!

```sh
GLOBUS_CONFIG_DIR=~/gcp/globus_config
GLOBUS_DATA_DIR=~/gcp/data

docker run \
    -v "$GLOBUS_CONFIG_DIR:/var/gcp/globus_config" \
    -v "$GLOBUS_DATA_DIR:/var/gcp/data" \
    -it globus
```

## Set up GCP endpoint

Once the container is running, you can set up the Globus Connect Personal
endpoint by running the following commands:

```sh
chown -R gridftp:gridftp /var/gcp
```

```sh
su - gridftp
```

```sh
globus login --no-local-server
```

### Collect information about endpoint

```sh
ENDPOINT_INFO=$(globus gcp create mapped myep 2>&1)
```

```sh
ENDPOINT_ID=$(echo "$ENDPOINT_INFO" | grep -oP 'Collection ID:\s+\K[0-9a-f-]+')
```

```sh
SETUP_KEY=$(echo "$ENDPOINT_INFO" | grep -oP 'Setup Key:\s+\K[0-9a-f-]+')
```

### Set env vars

```sh
export GLOBUS_ENDPOINT_ID="$ENDPOINT_ID"
```

```sh
export GLOBUS_SETUP_KEY="$SETUP_KEY"
```

### Finish endpoint setup

NB, because we switched to the gridftp user earlier, we should be in
`/home/gridftp`.

```sh
cd globusconnectpersonal-* \
&& ./globusconnectpersonal -setup "$GLOBUS_SETUP_KEY"
```

### Start endpoint and persist config

```sh
./globusconnectpersonal -start &
```

```sh
echo /var/gcp/data,0,1 >> ~/.globusonline/lta/config-paths \
&& cp -pR ~/.globus* /var/gcp/globus_config/
```

## Start already-set-up endpoint

Again, adjust paths on the host side as appropriate!

```sh
GLOBUS_CONFIG_DIR=~/gcp/globus_config
GLOBUS_DATA_DIR=~/gcp/data

docker run \
    -e START_GLOBUS='true' \
    -v "$GLOBUS_CONFIG_DIR:/var/gcp/globus_config" \
    -v "$GLOBUS_DATA_DIR:/var/gcp/data" \
    -it globus
```

It may be preferable to run the container in the background:

```sh
GLOBUS_CONFIG_DIR=~/gcp/globus_config
GLOBUS_DATA_DIR=~/gcp/data

docker run \
    -e START_GLOBUS='true' \
    -v "$GLOBUS_CONFIG_DIR:/var/gcp/globus_config" \
    -v "$GLOBUS_DATA_DIR:/var/gcp/data" \
    -d globus
```
