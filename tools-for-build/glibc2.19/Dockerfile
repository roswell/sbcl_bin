FROM ubuntu:14.04
RUN apt-get update && apt-get install -y \
    build-essential git automake libcurl4-openssl-dev curl software-properties-common \
 && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
 && apt-get update && apt-get install -y gcc-9 g++-9 \
 && (apt-get install -y gcc-9-multilib || apt-get install -y gcc-multilib || true ) \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 \
                        --slave /usr/bin/g++ g++ /usr/bin/g++-9 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;./configure --with-sbcl-bin-variant='-glibc2.19' ;make; make install; \
    cd /tmp;rm -rf /tmp/roswell; \
    (ros install sbcl-bin/2.4.7 || true);
run (ros install snmsts/sn.github || true)
