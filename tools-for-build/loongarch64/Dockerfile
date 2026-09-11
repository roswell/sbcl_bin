FROM ghcr.io/loong64/debian:trixie
RUN apt-get update && env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential git automake libcurl4-openssl-dev curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;./configure --with-sbcl-bin-variant='-loongarch64' ;make; make install; \
    cd /tmp;rm -rf /tmp/roswell; \
    (ros install sbcl-bin || true);
run (ros install snmsts/sn.github || true)
