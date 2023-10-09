FROM docker.io/redhat/ubi8

ENV MXS_VERSION=6.4.10

RUN dnf -y install curl

# Update System
COPY epel-8.rpm .
RUN dnf -y localinstall epel-8.rpm && \
    dnf -y upgrade

# Install Some Basic Dependencies & MaxScale

RUN dnf clean expire-cache && \
    dnf -y localinstall bind-utils \
    findutils \
    less \
    monit \
    nano \
    ncurses \
    net-tools \
    openssl \
    procps-ng \
    rsyslog \
    tini \
    vim \
    wget

# Install Maxscale   
COPY maxscale-6.4.10.rpm .
RUN dnf -y localinstall maxscale-6.4.10.rpm && \
    dnf -y upgrade

# Copy Files To Image
#COPY config/maxscale.cnf /etc/
#COPY config/monit.d/ /etc/monit.d/
COPY maxscale-start /usr/bin/

# Chmod Some Files
RUN chmod +x /usr/bin/maxscale-start

# Expose MariaDB Port
EXPOSE 3306

# Expose REST API port
EXPOSE 8989

# Create Persistent Volume
VOLUME ["/var/lib/maxscale"]

# Copy Entrypoint To Image
#COPY scripts/docker-entrypoint.sh /usr/bin/

# Make Entrypoint Executable & Create Legacy Symlink
#RUN chmod +x /usr/bin/docker-entrypoint.sh && \
#    ln -s /usr/bin/docker-entrypoint.sh /docker-entrypoint.sh
# Clean System & Reduce Size

RUN dnf clean all && \
    rm -rf /var/cache/dnf && \
    sed -i 's|SysSock.Use="off"|SysSock.Use="on"|' /etc/rsyslog.conf && \
    sed -i 's|^.*module(load="imjournal"|#module(load="imjournal"|g' /etc/rsyslog.conf && \
    sed -i 's|^.*StateFile="imjournal.state")|#  StateFile="imjournal.state"\)|g' /etc/rsyslog.conf && \
    find /var/log -type f -exec cp /dev/null {} \; && \
    cat /dev/null > ~/.bash_history && \
    history -c

 

# Start Up

#ENTRYPOINT ["/usr/bin/tini","--","docker-entrypoint.sh"]

CMD maxscale-start && monit -I
#docker build -t local/maxscale:v0.1 .
#docker system prune -a