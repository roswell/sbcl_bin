FROM centos:6
run curl https://www.getpagespeed.com/files/centos6-eol.repo --output /etc/yum.repos.d/CentOS-Base.repo
run yum install -y centos-release-scl
run sed -i -e "s%#baseurl=http:\/\/mirror\.centos\.org\/centos\/6\/sclo\/\$basearch\/rh\/%baseurl=http://vault.centos.org/centos/\$releasever\/sclo\/\$basearch\/rh\/%g" \
              /etc/yum.repos.d/CentOS-SCLo-scl-rh.repo; \
    sed -i -e "s%# baseurl=http:\/\/mirror\.centos\.org\/centos\/6\/sclo\/\$basearch\/sclo\/%baseurl=http://vault.centos.org/centos/\$releasever\/sclo\/\$basearch\/sclo\/%g" \
              /etc/yum.repos.d/CentOS-SCLo-scl.repo
run yum update -y && yum install -y devtoolset-7
run yum -y install libcurl-devel glibc-devel.i686 libgcc.i686 git
run cd /tmp; git clone https://github.com/roswell/roswell; \
    cd /tmp/roswell;./bootstrap;./configure --with-sbcl-bin-variant='-glibc2.10';make; make install; \
    cd /tmp;rm -rf /tmp/roswell; \
    ros install sbcl-bin/2.3.11
run ln -s libcrypto.so.10 /usr/lib64/libcrypto.so; \
    ros dist use quicklisp 2021-08-07 ; \
    ros install snmsts/sn.github
