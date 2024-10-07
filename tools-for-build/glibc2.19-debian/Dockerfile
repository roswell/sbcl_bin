FROM debian:8-slim
RUN echo "deb http://snapshot.debian.org/archive/debian/20210326T030000Z jessie main" \
 > /etc/apt/sources.list \
 && echo "deb http://snapshot.debian.org/archive/debian-security/20210326T030000Z jessie/updates main" \
 >> /etc/apt/sources.list \
 && echo "deb http://snapshot.debian.org/archive/debian/20210326T030000Z jessie-updates main" \
 >> /etc/apt/sources.list \
 && apt-get update && apt-get install -y --force-yes \
    build-essential git automake libcurl4-openssl-dev curl \
 && (apt-get install -y --force-yes gcc-multilib || true ) \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;./configure --with-sbcl-bin-variant='-glibc2.19' ;make; make install; \
    cd /tmp;rm -rf /tmp/roswell; \
    (ros install sbcl-bin/2.4.7 || true);
run (ros install snmsts/sn.github || true)
