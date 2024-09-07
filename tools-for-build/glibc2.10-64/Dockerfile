FROM centos:6
run curl https://www.getpagespeed.com/files/centos6-eol.repo --output /etc/yum.repos.d/CentOS-Base.repo
run yum -y groupinstall "Development Tools"
run yum -y install libcurl-devel zlib-devel glibc-devel.i686 libgcc.i686 zlib-devel.i686
run yum -y install epel-release;yum -y install libzstd-devel
run cd /tmp; git clone https://github.com/facebook/zstd; \
    cd /tmp/zstd/lib; git checkout v1.4.5; \
    rm /usr/lib64/libzstd.so*; \
    make PREFIX=/usr LIBDIR=/usr/lib64 install-static; make clean; \
    make PREFIX=/usr LIBDIR=/usr/lib CFLAGS=-m32 install-static; make clean; \
    cd /tmp;rm -rf /tmp/zstd;
run cd /tmp;curl -O http://mirrors.kernel.org/gnu/gcc/gcc-5.5.0/gcc-5.5.0.tar.gz; \
    tar -zxf gcc-5.5.0.tar.gz; \
    yum -y install gmp-devel mpfr-devel libmpc-devel glibc-devel glibc-devel.i686 zip unzip jar; \
    cd /tmp/gcc-5.5.0; \
    ./configure; \
    make; \
    make install; \
    yum -y remove gcc; \
    ln -s /usr/local/bin/x86_64-unknown-linux-gnu-gcc-5.5.0 /usr/bin/gcc; \
    ln -s /usr/local/bin/x86_64-unknown-linux-gnu-c++ /usr/bin/c++; \
    ln -s /usr/local/bin/x86_64-unknown-linux-gnu-gcc /usr/bin/cc; \
    cd /tmp;rm -rf gcc-5.5.0 gcc-5.5.0.tar.gz
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;./configure --with-sbcl-bin-variant='-glibc2.10';make; make install; \
    cd /tmp;rm -rf /tmp/roswell; \
    ros install sbcl-bin/2.3.11
run ln -s libcrypto.so.10 /usr/lib64/libcrypto.so; \
    ros dist use quicklisp 2021-08-07 ; \
    ros install snmsts/sn.github
