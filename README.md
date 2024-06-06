# Globus-Personal-Docker

This repository contains a Dockerfile for building a Docker image that can be used to run a personal Globus Connect Server. The image is based on the [globus/globus-connect-server](https://hub.docker.com/r/globus/globus-connect-server) image, and adds a script that can be used to configure the server with a personal endpoint.

## Building the container

To build the container, run the following command:

```bash
docker build -t globus .
```

## Running the container

You need to start by running the container and doing the initial configuration. The following command will start the container and mount the necessary volumes:

```bash
DataPath=/home/ferroelectric/data/
ConfigPath=/home/ferroelectric/globus_config/
docker run -e DataPath=$DataPath \
           -e ConfigPath=$ConfigPath \
           -v $ConfigPath:$ConfigPath \
           -v $DataPath:$DataPath \
           -it globus
```

## Setup the Globus Personal Endpoint

Once the container is running, you can setup the Globus Personal Endpoint by running the following commands:

```bash
globus login --no-local-server
```

## Collect information about the endpoint

```bash
# Run the globus endpoint create command and capture the output
endpoint_info=$(globus endpoint create --personal myep 2>&1)

# Extract the Endpoint ID and Setup Key from the output using grep and awk
endpoint_id=$(echo "$endpoint_info" | grep -oP 'Endpoint ID: \K[0-9a-f-]+')
setup_key=$(echo "$endpoint_info" | grep -oP 'Setup Key: \K[0-9a-f-]+')

# Set the environment variables
export GLOBUS_ENDPOINT_ID="$endpoint_id"
export GLOBUS_SETUP_KEY="$setup_key"

cd /home/gridftp/globusconnectpersonal-**/
```

## Finish the Endpoint Setup

```bash
./globusconnectpersonal -setup $GLOBUS_SETUP_KEY
```

## Add Path and Start the Endpoint

```bash
./globusconnectpersonal -start &
echo "$DataPath,0,1" >> ~/.globusonline/lta/config-paths
cp -p -r /home/gridftp/.globus* $ConfigPath
```

## Once the Setup is complete the endpoint can be started using the following command:

```bash
DataPath=/home/ferroelectric/data &&
ConfigPath=/home/ferroelectric/globus_config &&
docker run -e DataPath="$DataPath"  \
           -e ConfigPath="$ConfigPath" \
           -e START_GLOBUS="true" \
           -v "$ConfigPath":"$ConfigPath" \
           -v "$DataPath":"$DataPath" \
           -it globus
```