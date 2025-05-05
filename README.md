# Globus-Personal-Container

This repository contains a Dockerfile for building an image that can be used to
run a Globus Connect Personal endpoint. The image is based on
[globus/globus-connect-server](https://hub.docker.com/r/globus/globus-connect-server),
and this adds a script that facilitates configuring a GCP endpoint.

## Build container

```sh
docker build --platform=linux/amd64 -t globus .
```

## Run container for initial setup

Adjust the host-side paths as appropriate, and make sure they exist!

```sh
GLOBUS_CONFIG_DIR=~/gcp/globus_config && \
GLOBUS_DATA_DIR=~/gcp/data && \
docker run \
    -v "$GLOBUS_CONFIG_DIR:/var/gcp/globus_config" \
    -v "$GLOBUS_DATA_DIR:/var/gcp/data" \
    -it globus
```

## Set up GCP endpoint

At this point, you should be in an interactive session _inside the container_.
The following command will switch to the `gridftp` user:

```sh
chown -R gridftp:gridftp /var/gcp && \
su - gridftp
```

Next, trigger the Globus login process. This is an unavoidable step and involves
copying a link, opening it in a browser, authenticating, copying the resulting
token, and pasting that back in the terminal.

```sh
globus login --no-local-server
```

**The next few steps also assume that you remain in the container session.**

### Collect endpoint info and set environment variables

```sh
ENDPOINT_INFO=$(globus gcp create mapped myep 2>&1) && \
export GLOBUS_ENDPOINT_ID=$(echo "$ENDPOINT_INFO" | grep -oP 'Collection ID:\s+\K[0-9a-f-]+') && \
export GLOBUS_SETUP_KEY=$(echo "$ENDPOINT_INFO" | grep -oP 'Setup Key:\s+\K[0-9a-f-]+')
```

### Finish endpoint setup

NB, because we switched to the `gridftp` user earlier, the working directory
should be `/home/gridftp`.

```sh
cd globusconnectpersonal-* && \
./globusconnectpersonal -setup "$GLOBUS_SETUP_KEY"
```

### Start endpoint and persist configuration

```sh
./globusconnectpersonal -start &
sleep 2 && \
echo /var/gcp/data,0,1 >> ~/.globusonline/lta/config-paths && \
cp -pR ~/.globus* /var/gcp/globus_config/
```

### Exit container session

Once the configuration is saved, you can exit the container, which will also
stop it. This is expected: the purpose was simply to set up the endpoint. Going
forward, you can (re)start the container in detached mode—see below—and the GCP
endpoint should come online automatically.

You will probably need to `exit` twice: once from the `gridftp` user back to
`root` in the container, and again to end the container session.

```sh
exit
```

## Start an already-set-up endpoint

Again, adjust paths on the host side as appropriate!

```sh
GLOBUS_CONFIG_DIR=~/gcp/globus_config && \
GLOBUS_DATA_DIR=~/gcp/data && \
docker run \
    -e START_GLOBUS='true' \
    -v "$GLOBUS_CONFIG_DIR:/var/gcp/globus_config" \
    -v "$GLOBUS_DATA_DIR:/var/gcp/data" \
    -d globus
```
