FROM redhat/ubi8

ENV MXS_VERSION=6.4.10

# Install Some Basic Dependencies & MaxScale
RUN dnf clean expire-cache && \
    dnf -y install bind-utils \
    findutils \
    less \
    nano \
    ncurses \
    net-tools \
    openssl \
    procps-ng \
    rsyslog \
    curl \
    wget

# Install Maxscale   
COPY maxscale-6.4.10.rpm /tmp
RUN dnf -y localinstall /tmp/maxscale-6.4.10.rpm

# Copy Files To Image
COPY maxscale.cnf /etc/
COPY maxscale-start /usr/bin/

# Chmod Some Files
RUN chmod +x /usr/bin/maxscale-start && mkdir -p /maxscale/logs/maxscale_logs

# Expose MariaDB Port
EXPOSE 3306

# Expose REST API port
EXPOSE 8989

# Create Persistent Volume
VOLUME ["/var/lib/maxscale"]
VOLUME ["/maxscale/logs/maxscale_logs"]

RUN touch /maxscale/logs/maxscale_logs/maxscale.log && chown -R maxscale:maxscale /maxscale

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
CMD maxscale-start && tail -vf -n +1 /maxscale/logs/maxscale_logs/maxscale.log
# ;~)
