FROM ubuntu:18.04

RUN apt-get update \
 && apt-get install -y curl python python3 libatomic1 libgtk2.0-dev libglapi-mesa libxdamage1 libc6 libxfixes3 \
                       libxcb-glx0 libxcb-dri2-0 libxcb-dri3-0 libxcb-present0 libxcb-sync1 libxshmfence1 libxxf86vm1  \
 && apt-get clean

RUN adduser --system --home /dropbox --shell /bin/bash --group dropbox

RUN [ -d /dropbox ] || mkdir /dropbox
ENV DROPBOX_VERSION 100.4.409 
RUN cd /dropbox && curl -L "https://www.dropbox.com/download?plat=lnx.x86_64&v=$DROPBOX_VERSION" | tar xzf -
RUN cd /usr/bin && curl -L -o dropbox-cli "https://www.dropbox.com/download?dl=packages/dropbox.py&v=$DROPBOX_VERSION"
RUN chmod +x /usr/bin/dropbox-cli

RUN chown -R dropbox:dropbox /dropbox

RUN mkdir -p /opt/dropbox \
  # Prevent dropbox to overwrite its binary
  && mv /dropbox/.dropbox-dist/dropbox-lnx* /opt/dropbox/ \
  && mv /dropbox/.dropbox-dist/dropboxd /opt/dropbox/ \
  && mv /dropbox/.dropbox-dist/VERSION /opt/dropbox/ \
  && rm -rf /dropbox/.dropbox-dist \
  && install -dm0 /dropbox/.dropbox-dist \
  # Prevent dropbox to write update files
  && chmod u-w /dropbox \
  && chmod o-w /tmp \
  && chmod g-w /tmp \
  && chmod 755 /opt/dropbox/dropbox-lnx*/*.so

VOLUME /dropbox/Dropbox
VOLUME /dropbox/.dropbox

EXPOSE 17500

ADD dropbox /usr/bin/dropbox
ADD start.sh /root/start.sh

WORKDIR /dropbox/Dropbox
ENTRYPOINT ["/root/start.sh"]
