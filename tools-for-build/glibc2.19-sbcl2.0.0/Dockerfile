FROM ubuntu:14.04
RUN apt-get update && apt-get install -y \
    build-essential git automake libcurl4-openssl-dev curl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
run env LISP=sbcl-bin/2.0.0 bash -c 'curl -L https://raw.githubusercontent.com/roswell/roswell/release/scripts/install-for-ci.sh | sh'
run ros install snmsts/sn.github
