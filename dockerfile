# Globus Connect/GridFTP container
# https://www.globus.org/globus-connect-server
# includes GridFTP and Globus Connect
# also includes some network test tools
# Nadya Williams: add globusconnectpersonal tools
# to globus-connect created by John Graham

FROM rockylinux:9
LABEL MAINTAINER Nadya Williams <nwilliams@ucsd.edu>
LABEL CONTRIBUTER Kyle Krick <kkrick@sdsu.edu>

RUN yum -y update; yum clean all && \
    yum -y install wget rsync openssh-clients python pip && \
    yum -y install epel-release && \
    yum -y update; yum clean all && \
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    # dnf -y install https://downloads.globus.org/globus-connect-server/stable/installers/repo/rpm/globus-repo-latest.noarch.rpm && \
    # dnf -y install 'dnf-command(config-manager)' && \
    # dnf -y install globus-connect-server54 && \
    pip3 install --upgrade globus-cli && \
    adduser gridftp

RUN cd /root && \
    wget https://downloads.globus.org/globus-connect-personal/linux/stable/globusconnectpersonal-latest.tgz && \
    tar xzvf /root/globusconnectpersonal-latest.tgz -C /home/gridftp && \
    chown -R gridftp.gridftp /home/gridftp/globus*

ADD gridftp.conf /etc/gridftp.conf
ADD globus-connect-server.conf /etc/globus-connect-server.conf
ADD --chown=gridftp:gridftp --chmod=744 globus-connect-personal.sh /home/gridftp/globus-connect-personal.sh

# globus-connect-server-setup script needs these
ENV HOME /root
ENV TERM xterm
