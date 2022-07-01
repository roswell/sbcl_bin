FROM centos:6
run curl https://www.getpagespeed.com/files/centos6-eol.repo --output /etc/yum.repos.d/CentOS-Base.repo
run yum -y groupinstall "Development Tools"
run yum -y install libcurl-devel zlib-devel glibc-devel.i686 libgcc.i686 zlib-devel.i686
run yum -y install epel-release;yum -y install libzstd-devel
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;./configure --with-sbcl-bin-variant='-glibc2.10';make; make install; \
    ros install sbcl-bin/2.0.5
run ros dist use quicklisp 2021-08-07 ; ros install snmsts/sn.github
