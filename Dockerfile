FROM rockylinux:9

# Default value for starting GCP, overridden on subsequent runs
ENV START_GLOBUS=false

# Update system, install required packages, install globus-cli, and add gridftp user
RUN dnf -y update && \
    dnf -y install wget rsync openssh-clients python3 python3-pip && \
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    dnf clean all && \
    pip3 install --upgrade globus-cli && \
    adduser gridftp

# Download and extract Globus Connect Personal (downloading to /tmp, then cleaning up)
RUN wget -O /tmp/globusconnectpersonal-latest.tgz \
    https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz && \
    tar xzf /tmp/globusconnectpersonal-latest.tgz -C /home/gridftp && \
    rm /tmp/globusconnectpersonal-latest.tgz

# Copy startup script, make it executable, and set ownership
COPY globus-connect-personal.sh /home/gridftp/
RUN chmod +x /home/gridftp/globus-connect-personal.sh && \
    chown -R gridftp:gridftp /home/gridftp

# Launch GCP, or an interactive shell if configuration is needed
CMD if [ "$START_GLOBUS" = "true" ]; then \
    echo "Starting Globus Connect Personal" && \
    su - gridftp -c "/home/gridftp/globus-connect-personal.sh"; \
    else \
    exec /bin/bash -i; \
    fi
