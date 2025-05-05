#! /usr/bin/env bash

# Summary: This shell script will check for a Globus Connect Personal (GCP)
# endpoint & start it if it exists, otherwise it will sleep for an hour giving
# the user time to login and configure the GCP endpoint.

# Note: This script assumes that the user follows the directions in the README.

echo 'Running Globus Connect Personal script'

###  Variables  ###

# GCP config is stored in the .globusonline directory
GCP_CONFIG_DIR='.globusonline'

# GCP installation directory; version and path may change so find dynamically
GCP_DIR=$(find . -maxdepth 1 -type d -name "globusconnectpersonal-*" -print -quit)

MAPPED_CONFIG_DIR='/var/gcp/globus_config'

###  Script Start  ###

# Check to make sure GCP_DIR exists
if [[ ! -d "$GCP_DIR" ]]; then
	echo "Error: Globus Connect Personal directory not found"
	exit 1
fi

# Check for existing GCP configuration
if [[ -d "$GCP_CONFIG_DIR" ]]; then
	echo "Found existing GCP configuration. Starting endpoint..."
	exec "$GCP_DIR/globusconnectpersonal" -start
fi

# Check mounted config directory
if [[ -d "$MAPPED_CONFIG_DIR/$GCP_CONFIG_DIR" ]]; then
	echo "Copying existing GCP configuration..."
	cp -pr "$MAPPED_CONFIG_DIR"/.glob* "$HOME/"
	exec "$GCP_DIR/globusconnectpersonal" -start
fi

# No config found; sleep for an hour to give user time to configure
echo "No Globus Connect Personal configuration found"
echo "Please log in and configure your endpoint"
echo "Sleeping for an hour..."
sleep 3600
