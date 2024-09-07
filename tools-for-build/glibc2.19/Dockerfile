FROM ubuntu:14.04
RUN apt-get update && apt-get install -y \
    build-essential git automake libcurl4-openssl-dev curl \
 && (apt-get install -y gcc-multilib lib32z1-dev || true ) \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
run ln -s /usr/include/x86_64-linux-gnu/zconf.h /usr/include
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;./configure ;make; make install; \
    cd /tmp;rm -rf /tmp/roswell; \
    ros install sbcl-bin/2.3.11;
run ros install snmsts/sn.github
