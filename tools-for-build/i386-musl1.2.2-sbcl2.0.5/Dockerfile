FROM i386/alpine:3.13
run apk add --no-cache alpine-sdk automake autoconf curl-dev bash linux-headers util-linux
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;setarch i686 ./configure --with-sbcl-bin-variant='-musl';make; make install; \
    ros install sbcl-bin/2.0.5
run ros install snmsts/sn.github
