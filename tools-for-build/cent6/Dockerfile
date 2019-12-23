FROM centos:6
run yum -y groupinstall "Development Tools"
run yum -y install libcurl-devel zlib-devel glibc-devel.i686 libgcc.i686 zlib-devel.i686
run env LISP=sbcl-bin/1.5.7 bash -c 'curl -L https://raw.githubusercontent.com/roswell/roswell/release/scripts/install-for-ci.sh | sh'
run ros install snmsts/sn.github
