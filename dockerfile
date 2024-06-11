# Globus Connect/GridFTP container
# https://www.globus.org/globus-connect-server
# includes GridFTP and Globus Connect
# also includes some network test tools
# Nadya Williams: add globusconnectpersonal tools
# to globus-connect created by John Graham

FROM rockylinux:9
LABEL MAINTAINER Nadya Williams <nwilliams@ucsd.edu>
LABEL CONTRIBUTER Kyle Krick <kkrick@sdsu.edu>

VOLUME /home/ferroelectric/globus_config
VOLUME /home/ferroelectric/data

# Install necessary packages
RUN yum -y update && \
    yum -y install wget rsync openssh-clients epel-release && \
    yum -y update && \
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    yum -y install python3 python3-pip && \
    pip3 install --upgrade globus-cli && \
    adduser gridftp

# Install DataFed CLI
RUN pip3 install datafed
RUN pip3 install protobuf==3.20.0

# Download and setup Globus Connect Personal
RUN cd /root && \
    wget https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz && \
    tar xzvf /root/globusconnectpersonal-latest.tgz -C /home/gridftp && \
    chown -R gridftp.gridftp /home/gridftp/globus*

# Copy the script into the container
COPY globus-connect-personal.sh /home/gridftp/globus-connect-personal.sh

# Make the script executable
RUN chmod +x /home/gridftp/globus-connect-personal.sh

# Set the command to execute
CMD if [ "$START_GLOBUS" = "true" ]; then \
    echo "Starting Globus Connect Personal"; \
    su gridftp -c 'cd /home/gridftp && source ./globus-connect-personal.sh'; \
    /bin/bash -i; \
    else \
    /bin/bash -i; \
    fi

# globus-connect-server-setup script needs these
ENV HOME /root
ENV TERM xterm

# Set default value for RUN_SETUP_SCRIPT
ENV START_GLOBUS=false


