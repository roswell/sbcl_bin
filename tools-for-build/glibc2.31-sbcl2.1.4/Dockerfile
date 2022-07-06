FROM ubuntu:20.04
RUN apt-get update && env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential git automake libcurl4-openssl-dev curl gcc-multilib lib32z1-dev \
    dh-autoreconf bash-completion \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;./configure ;make; make install; \
    cd /tmp;rm -rf /tmp/roswell; \
    ros install sbcl-bin/2.1.4; \
    cd /tmp; git clone https://github.com/facebook/zstd; \
    cd /tmp/zstd/lib; make PREFIX=/usr install-includes install-static; make clean; \
    make PREFIX=/usr LIBDIR=/usr/lib32 CFLAGS=-m32 install-static; make clean;
run ros install snmsts/sn.github
