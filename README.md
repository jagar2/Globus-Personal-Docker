# Globus-Personal-Docker

This repository contains a Dockerfile for building a Docker image that can be
used to run a personal Globus Connect Server. The image is based on the
[globus/globus-connect-server](https://hub.docker.com/r/globus/globus-connect-server)
image, and adds a script that can be used to configure the server with a
personal endpoint.

## Building the container

To build the container, run the following command:

```sh
docker build -t globus .
```

## Running the container

You need to start by running the container and doing the initial configuration.
The following command will start the container and mount the necessary volumes:

```sh
docker run \
         -v ~/gcp/globus_config:/var/gcp/globus_config \
         -v ~/gcp/data:/var/gcp/data \
         -it globus
```

## Setup the Globus Personal Endpoint

Once the container is running, you can setup the Globus Personal Endpoint by
running the following commands:

```sh
globus login --no-local-server
```

## Collect information about the endpoint

```sh
endpoint_info=$(globus endpoint create --personal myep 2>&1)
```

```sh
endpoint_id=$(echo "$endpoint_info" | grep -oP 'Endpoint ID: \K[0-9a-f-]+')
```

```sh
setup_key=$(echo "$endpoint_info" | grep -oP 'Setup Key: \K[0-9a-f-]+')
```

## Set the environment variables

```sh
export GLOBUS_ENDPOINT_ID="$endpoint_id"
```

```sh
export GLOBUS_SETUP_KEY="$setup_key"
```

```sh
cd /home/gridftp/globusconnectpersonal-**
```

## Finish the Endpoint Setup

```sh
./globusconnectpersonal -setup $GLOBUS_SETUP_KEY
```

## Add Path and Start the Endpoint

```sh
./globusconnectpersonal -start &
echo "/var/gcp/data,0,1" >> ~/.globusonline/lta/config-paths
cp -pr "/home/gridftp/.globus*" /var/gcp/globus_config
```

## Once the Setup is complete the endpoint can be started using the following command

```sh
docker run \
         -e START_GLOBUS='true' \
         -v ~/gcp/globus_config:/var/gcp/globus_config \
         -v ~/gcp/data:/var/gcp/data \
         -it globus
```
