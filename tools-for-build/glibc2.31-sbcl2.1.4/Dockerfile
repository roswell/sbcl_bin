FROM ubuntu:20.04
RUN apt-get update && env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential git automake libcurl4-openssl-dev curl gcc-multilib lib32z1-dev \
    dh-autoreconf bash-completion \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
run env LISP=sbcl-bin/2.1.4 bash -c 'curl -L https://raw.githubusercontent.com/roswell/roswell/release/scripts/install-for-ci.sh | sh'
run ros install snmsts/sn.github
