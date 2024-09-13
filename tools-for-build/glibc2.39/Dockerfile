FROM ubuntu:24.04
RUN apt-get update && env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential git automake libcurl4-openssl-dev curl \
 && (env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gcc-multilib lib32z1-dev || true )  \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;./configure --with-sbcl-bin-variant=-glibc2.39 ;make; make install; \
    cd /tmp;rm -rf /tmp/roswell; \
    (ros install sbcl-bin/2.3.11 || true)
run (ros install snmsts/sn.github || true)
