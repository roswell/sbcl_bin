FROM alpine:3.12
run apk add --no-cache alpine-sdk automake autoconf curl-dev bash linux-headers
ARG WRAPPER=""
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;$WRAPPER ./configure --with-sbcl-bin-variant='-musl1.1';make; make install; \
    cd /tmp;rm -rf /tmp/roswell; \
    ros install sbcl-bin/2.4.7;

run ros install snmsts/sn.github
