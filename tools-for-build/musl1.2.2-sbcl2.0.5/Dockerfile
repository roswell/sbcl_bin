FROM alpine:3.13
run apk add --no-cache alpine-sdk automake autoconf curl-dev bash
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;./configure --with-sbcl-bin-variant='-musl';make; make install; \
    ros install sbcl-bin/2.0.5
run ros install snmsts/sn.github
