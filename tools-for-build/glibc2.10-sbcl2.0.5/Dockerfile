FROM centos:6
run curl https://www.getpagespeed.com/files/centos6-eol.repo --output /etc/yum.repos.d/CentOS-Base.repo
run yum -y groupinstall "Development Tools"
run yum -y install libcurl-devel zlib-devel glibc-devel.i686 libgcc.i686 zlib-devel.i686
run yum -y install epel-release;yum -y install libzstd-devel
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;./configure --with-sbcl-bin-variant='-glibc2.10';make; make install; \
    cd /tmp;rm -rf /tmp/roswell; \
    ros install sbcl-bin/2.0.5; \
    rm /usr/lib64/libzstd.so*; \
    cd /tmp; git clone https://github.com/facebook/zstd; \
    cd /tmp/zstd/lib; git checkout v1.4.5; \
    make PREFIX=/usr LIBDIR=/usr/lib64 install-static; make clean; \
    make PREFIX=/usr LIBDIR=/usr/lib CFLAGS=-m32 install-static; make clean; \
    cd /tmp;rm -rf /tmp/zstd
run ros dist use quicklisp 2021-08-07 ; ros install snmsts/sn.github
