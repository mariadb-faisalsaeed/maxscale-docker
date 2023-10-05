FROM docker.io/mariadb/maxscale:6.4.10

COPY entrypoint.sh /entrypoint.sh
COPY encrypt_pwd.sh /tmp

RUN chmod g=u /etc/passwd && \
    chmod +x entrypoint.sh && \
    chmod +x /tmp/encrypt_pwd.sh && \
    chmod -R g=u /var/{lib,run,log,cache}/maxscale && \
    chgrp -R 0 /var/{lib,run,log,cache}/maxscale

COPY maxscale.cnf /etc/maxscale.cnf

RUN mkdir -p /maxscale/logs/maxscale_logs
RUN chown -R maxscale:maxscale /maxscale && \
    chown maxscale:maxscale /etc/maxscale.cnf

ARG MONITORPWD=P@ssw0rd
ARG SERVICEPWD=P@ssw0rd
ARG REPPWD=P@ssw0rd

RUN maxkeys

RUN maxpasswd ${MONITORPWD} >> /tmp/monitor_password.txt && \
    maxpasswd ${SERVICEPWD} >> /tmp/service_password.txt && \
    maxpasswd ${REPPWD} >> /tmp/rep_password.txt

RUN sed -i "s/{RepPWD}/$(cat /tmp/rep_password.txt)/g" /etc/maxscale.cnf
RUN sed -i "s/{MonPWD}/$(cat /tmp/monitor_password.txt)/g" /etc/maxscale.cnf
RUN sed -i "s/{SvcPWD}/$(cat /tmp/service_password.txt)/g" /etc/maxscale.cnf

#RUN /tmp/encrypt_pwd.sh

USER maxscale

ENTRYPOINT ["/entrypoint.sh"]
CMD ["maxscale", "--nodaemon", "--log=stdout"]

EXPOSE 4404 4405 4406

ENV MONITOR_USER=${MONITORUSER} \
    MONITOR_PWD=${MONITORPWD} \
    SERVICE_USER=${SERVICEUSER} \
    SERVICE_PWD=${SERVICEPWD} \
    REP_PWD=${REPPWD} \
    READ_WRITE_SPLIT_PORT=4404 \
    READ_ONLY_SLAVE_PORT=4406 \
    READ_WRITE_MASTER_PORT=4405

#docker build -t local/maxscale:v0.1 .
#docker system prune -a