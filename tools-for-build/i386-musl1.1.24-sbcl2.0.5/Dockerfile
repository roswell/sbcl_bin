FROM i386/alpine:3.12
run apk add --no-cache alpine-sdk automake autoconf curl-dev bash linux-headers util-linux zstd-dev
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;setarch i686 ./configure --with-sbcl-bin-variant='-musl1.1';make; make install; \
    cd /tmp;rm -rf /tmp/roswell; \
    ros install sbcl-bin/2.3.11; \
    rm /usr/lib/libzstd.so*; \
    cd /tmp; git clone https://github.com/facebook/zstd; \
    cd /tmp/zstd/lib; git checkout v1.4.9; make PREFIX=/usr install-static; \
    cd /tmp;rm -rf /tmp/zstd

run ros install snmsts/sn.github
