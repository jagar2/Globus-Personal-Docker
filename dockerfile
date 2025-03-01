FROM rockylinux:9

# Env var defaults
ENV HOME /root
ENV TERM xterm
ENV START_GLOBUS=false

# Install necessary packages
RUN dnf -y update && \
    dnf -y install wget rsync openssh-clients python3 python3-pip && \
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    dnf clean all && \
    pip3 install --upgrade globus-cli && \
    adduser gridftp

# We will bind mount these directories
RUN mkdir -p /var/gcp/globus_config /var/gcp/data && \
    chown -R gridftp:gridftp /var/gcp

# Download and extract Globus Connect Personal
RUN wget -O /root/globusconnectpersonal-latest.tgz \
    https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz && \
    tar xzf /root/globusconnectpersonal-latest.tgz -C /home/gridftp

# Copy script into container; make it executable; give gridftp ownership
COPY globus-connect-personal.sh /home/gridftp/
RUN chmod +x /home/gridftp/globus-connect-personal.sh && \
    chown -R gridftp:gridftp /home/gridftp

CMD if [ "$START_GLOBUS" = "true" ]; then \
    echo "Starting Globus Connect Personal" && \
    su - gridftp -c "/home/gridftp/globus-connect-personal.sh" && \
    exec /bin/bash -i; \
    else \
    exec /bin/bash -i; \
    fi
