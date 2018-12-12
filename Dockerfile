FROM ubuntu:18.04

ADD entrypoint.sh /bin/entrypoint.sh
ADD s3ql_chain.sh /bin/s3ql_chain.sh

RUN  export DEBIAN_FRONTEND=noninteractive && \
     apt-get update && \
     apt-get -y install s3ql wget apt-transport-https apt-utils gnupg2 && \
     apt-get -y install vnc4server python expect jwm locales libqt5widgets5 libqt5x11extras5 libidn11 && \
     mkdir -p /root/.vnc && \
     ln -s /usr/bin/jwm /root/.vnc/xstartup && \
     mkdir /root/Cloud\ Mail.Ru && \
     locale-gen ru_RU.UTF-8
RUN wget http://r.mail.ru/n183758973 -O mail.ru-cloud_15.06.0110_amd64.deb && \
    dpkg -i mail.ru-cloud_15.06.0110_amd64.deb

# Set environment variables.
ENV LANG ru_RU.UTF-8
ENV HOME /root
ENV USER root
ENV DISPLAY :0
ENV VNCPASS changeme

# Define working directory.
WORKDIR /root

# Define default command.
# vncserver

EXPOSE 5900
ENTRYPOINT ["/bin/entrypoint.sh"]
