# Globus-Personal-Docker

This repository contains a Dockerfile for building a Docker image that can be
used to run a Globus Connect Personal endpoint. The image is based on the
[globus/globus-connect-server](https://hub.docker.com/r/globus/globus-connect-server)
image, and adds a script that can be used to configure the server with a
personal endpoint.

## Build container

```sh
docker build -t globus .
```

## Run container for setup

```sh
docker run \
         -v ~/gcp/globus_config:/var/gcp/globus_config \
         -v ~/gcp/data:/var/gcp/data \
         -it globus
```

## Set up GCP endpoint

Once the container is running, you can set up the Globus Connect Personal
endpoint by running the following commands:

```sh
su - gridftp
```

```sh
globus login --no-local-server
```

### Collect information about endpoint

```sh
ENDPOINT_INFO=$(globus endpoint create --personal myep 2>&1)
```

```sh
ENDPOINT_ID=$(echo "$ENDPOINT_INFO" | grep -oP 'Endpoint ID: \K[0-9a-f-]+')
```

```sh
SETUP_KEY=$(echo "$ENDPOINT_INFO" | grep -oP 'Setup Key: \K[0-9a-f-]+')
```

### Set env vars

```sh
export GLOBUS_ENDPOINT_ID="$ENDPOINT_ID"
```

```sh
export GLOBUS_SETUP_KEY="$SETUP_KEY"
```

### Finish endpoint setup

```sh
cd /home/gridftp/globusconnectpersonal-**
```

```sh
./globusconnectpersonal -setup $GLOBUS_SETUP_KEY
```

### Add path and start endpoint

```sh
./globusconnectpersonal -start &
echo "/var/gcp/data,0,1" >> ~/.globusonline/lta/config-paths
cp -pr "/home/gridftp/.globus*" /var/gcp/globus_config
```

## Start already-set-up endpoint

```sh
docker run \
         -e START_GLOBUS='true' \
         -v ~/gcp/globus_config:/var/gcp/globus_config \
         -v ~/gcp/data:/var/gcp/data \
         -it globus
```
