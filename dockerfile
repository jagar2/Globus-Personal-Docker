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

# Install necessary packages and development tools
RUN dnf -y update && \
    dnf -y install wget rsync openssh-clients epel-release gcc make openssl-devel bzip2-devel libffi-devel zlib-devel sqlite-devel && \
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

# Install Python 3.11 from source
RUN cd /usr/src && \
    wget https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tgz && \
    tar xzf Python-3.11.0.tgz && \
    cd Python-3.11.0 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    ln -s /usr/local/bin/python3.11 /usr/bin/python3.11 && \
    ln -s /usr/local/bin/pip3.11 /usr/bin/pip3.11

# Set Python 3.11 as the default python3 and pip3
RUN ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
    ln -sf /usr/bin/pip3.11 /usr/bin/pip3

# Upgrade pip and install necessary Python packages
RUN pip3 install --upgrade pip && \
    pip3 install --upgrade globus-cli

# Add user for gridftp
RUN adduser --home /home/gridftp --shell /bin/bash gridftp

# Copy the requirements.txt file into the container
COPY requirements.txt .

# Install the Python packages specified in requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# Install Qt dependencies
RUN dnf -y install qt5-qtbase qt5-qtmultimedia qt5-qtdeclarative

# Download and setup Globus Connect Personal
RUN cd /root && \
    wget https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz && \
    tar xzvf /root/globusconnectpersonal-latest.tgz -C /home/gridftp && \
    chown -R gridftp:gridftp /home/gridftp/globus*

# Copy the script into the container
COPY globus-connect-personal.sh /home/gridftp/globus-connect-personal.sh

# Make the script executable
RUN chmod +x /home/gridftp/globus-connect-personal.sh

# Set permissions for .bashrc if needed
RUN chmod 644 /root/.bashrc

# Set root password
RUN echo "root:password" | chpasswd

# Switch to the gridftp user for subsequent operations
USER gridftp

# Set the command to execute
CMD if [ "$START_GLOBUS" = "true" ]; then \
    su gridftp; \
    echo "Starting Globus Connect Personal"; \
    cd /home/gridftp && ./globus-connect-personal.sh && /bin/bash -i; \
    else \
    su gridftp -c /bin/bash -i; \
    fi

# globus-connect-server-setup script needs these
ENV HOME /root
ENV TERM xterm

# Set default value for START_GLOBUS
ENV START_GLOBUS=false
