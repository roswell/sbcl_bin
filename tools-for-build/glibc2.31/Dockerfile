FROM ubuntu:20.04
RUN apt-get update && env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential git automake libcurl4-openssl-dev curl \
    dh-autoreconf bash-completion \
 && (env DEBIAN_FRONTEND=noninteractive apt-get install -y gcc-multilib || true) \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;./configure ;make; make install; \
    cd /tmp;rm -rf /tmp/roswell; \
    (ros install sbcl-bin/2.4.7 || true);
run (ros install snmsts/sn.github || true)
