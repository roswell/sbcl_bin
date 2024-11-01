FROM ubuntu:24.04
run apt-get update && env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    bzip2 xz-utils git automake curl make \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
run cd /tmp; curl -L -O https://github.com/roswell/roswell/releases/download/v24.10.115/roswell-24.10.115-linux-`uname -m`.tar.bz2 \
 && cd /tmp; tar xf roswell-24.10.115-linux-`uname -m`.tar.bz2 \
 && cd /tmp/roswell; make install \
 && cd /tmp;rm -rf /tmp/roswell roswell*.bz2 \
 && (ros install sbcl-bin/2.4.0 || true)
run (ros install snmsts/sn.github || true)
run cd /root;curl -L -O https://ziglang.org/download/0.13.0/zig-linux-`uname -m`-0.13.0.tar.xz \
 && cd /root;tar xf zig-linux-`uname -m`-0.13.0.tar.xz \
 && cd /root;mv zig-linux-*-0.13.0 zig \
 && rm /root/zig-linux*.xz
