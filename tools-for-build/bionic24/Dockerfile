FROM termux/termux-docker:latest
# `pkg` refuses to run as root, so install as the uid the image is built around.
USER system
# The stock sources.list points at a CDN that resolves to whichever regional
# mirror is nearest the runner; some of those stall at a few tens of kB/s and
# fail the fetch outright. Pin the canonical host instead.
RUN echo "deb https://packages.termux.dev/apt/termux-main stable main" \
      > "$PREFIX/etc/apt/sources.list" \
 && pkg install -y clang make binutils git \
 && clang -dumpmachine
# The lisp side (make-host-1/2) runs on the runner, never in here, but
# make-config.sh still interpolates --xc-host into output/build-config, so a
# `ros` that merely exists is enough.
RUN printf '#!%s/bin/sh\nexit 0\n' "$PREFIX" > "$PREFIX/bin/ros" \
 && chmod +x "$PREFIX/bin/ros" \
 && ros run
# The stock entrypoint drops root to uid 1000, which then cannot write to the
# bind-mounted workspace the runner owns. Build as root instead.
USER root
ENTRYPOINT []
