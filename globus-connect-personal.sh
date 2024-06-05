#!/bin/env bash

# Summary: This shell script will check for a Globus Connect Personal (GCP) 
# endpoint & start it if it exists, otherwise it will sleep for an hour giving 
# the user time to login and configure the GCP endpoint.

# Note: This script assumes that the user follows the directions in the README.

# Author: Kyle Krick <kkrick@sdsu.edu>

###  Variables  ###

# GCP config is stored in the .globusonline directory
gcpconfigdir=.globusonline
# GCP intallation directory, version and path may change so find dynamically
gcpdir=$(find . -maxdepth 1 -type d -name "globusconnectpersonal-*" -print -quit)

###  Script Start  ###

cd /home/gridftp

# Check to make sure globusconnectpersonal exists
if [ ! -d "$gcpdir" ]; then
    exit 1
fi

# Check /home/gridftp for existing GCP config
if [ -d "$gcpconfigdir" ]; then
    # GCP endpoint config exists, start the endpoint
    "./$gcpdir/globusconnectpersonal" -start
else
    # Check /data/gridftp-save for GCP endpoint config
    if [ -d "/data/gridftp-save/$gcpconfigdir" ]; then
        # Copy existing config and then start GCP endpoint
        cp -p -r /data/gridftp-save/.glob* ~
        "./$gcpdir/globusconnectpersonal" -start
    else
        # Can't find GCP config, sleep for an hour to let user set up config
        sleep 3600
    fi
fi

