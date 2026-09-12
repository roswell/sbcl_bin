FROM raspbian_armhf:2017-07-05
RUN rm -f /etc/apt/sources.list.d/collabora.list /etc/apt/sources.list.d/raspi.list; \
    echo deb http://legacy.raspbian.org/raspbian/ jessie main contrib non-free rpi > /etc/apt/sources.list; \
    apt-get update && apt-get install -y \
    build-essential git automake libcurl4-openssl-dev curl \
 && (apt-get install -y gcc-multilib || true ) \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;./configure --with-sbcl-bin-variant='-glibc2.19' ;make; make install; \
    cd /tmp;rm -rf /tmp/roswell; \
    (ros install sbcl-bin/2.4.8 || true);
run (ros install snmsts/sn.github || true)
