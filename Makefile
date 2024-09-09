#sbcl_bin
-include .env
export $(shell sed 's/=.*//' .env)

NOP := $(shell ros build.ros nop) # avoid messages compile.
BRANCH ?= $(shell ros build.ros branch)
VERSION ?= $(shell ros build.ros version)
VERSION_SUFFIX ?= .roswell
ARCH ?= $(shell ros build.ros uname)
SUFFIX ?=
TARGETS ?=$(ARCH)
SBCL_OPTIONS ?=--fancy
LISP_IMPL ?= ros -L sbcl-bin without-roswell=t --no-rc run

DOCKER_REPO ?= docker.pkg.github.com/roswell/sbcl_bin
DOCKER_PLATFORM ?= linux/amd64
DOCKER_BUILD_OPTIONS ?=
DOCKER_IMAGE_SUFFIX ?=
DOCKER_ACTION ?= docker-default-action

ZSTD_BRANCH ?= v1.5.6

TSV_FILE ?= sbcl-bin_uri.tsv

clean:
	rm -rf zstd
	ls |grep sbcl |xargs rm -rf
show:
	@echo VERSION=$(VERSION) ARCH=$(ARCH) BRANCH=$(BRANCH) SUFFIX=$(SUFFIX)
	cc -x c -v -E /dev/null || true
	cc -print-search-dirs || true
sbcl:
	git clone --depth 5 https://github.com/sbcl/sbcl --branch=$(BRANCH) || git clone --depth 5 https://git.code.sf.net/p/sbcl/sbcl --branch=$(BRANCH)
zstd:
	git clone --depth 5 https://github.com/facebook/zstd --branch=$(ZSTD_BRANCH)

sbcl/version.lisp-expr: sbcl
	cd sbcl;echo '"$(VERSION)$(VERSION_SUFFIX)$(SUFFIX)"' > version.lisp-expr

compile: show sbcl
	cd sbcl;{ git describe  | sed -n -e 's/^.*-g//p' ; } 2>/dev/null > git_hash
	cat sbcl/git_hash
	rm -f sbcl/version.lisp-expr; $(MAKE) sbcl/version.lisp-expr
	mv sbcl/.git sbcl/_git
	cd sbcl;bash make.sh $(SBCL_OPTIONS) --arch=$(ARCH) --xc-host="$(LISP_IMPL)" || mv _git .git
	cd sbcl;bash make-shared-library.sh || true
	cd sbcl;bash run-sbcl.sh --eval "(progn (print *features*)(print (lisp-implementation-version))(terpri)(quit))"
	ldd sbcl/src/runtime/sbcl || otool -L sbcl/src/runtime/sbcl || true

archive:
	VERSION=$(VERSION) ARCH=$(ARCH) SUFFIX=$(SUFFIX) ros build.ros archive

tsv:
	TSV_FILE=$(TSV_FILE) ros web.ros tsv

#docker
debug-docker:
	docker run \
		--rm \
		-it \
		--platform $(DOCKER_PLATFORM) \
		-v `pwd`:/tmp \
		$(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name)$(DOCKER_IMAGE_SUFFIX) \
		bash

build-docker:
	docker build --platform $(DOCKER_PLATFORM) -t $(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name)$(DOCKER_IMAGE_SUFFIX) $(DOCKER_BUILD_OPTIONS) ./tools-for-build/$(IMAGE)
push-docker:
	docker push $(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name)$(DOCKER_IMAGE_SUFFIX);
pull-docker:
	docker pull $(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name)$(DOCKER_IMAGE_SUFFIX);
docker: zstd
	docker run \
		--rm \
		--platform $(DOCKER_PLATFORM) \
		-v `pwd`:/tmp \
		-e ARCH=$(ARCH) \
		-e VERSION=$(VERSION) \
		-e BRANCH=$(BRANCH) \
		-e SUFFIX=$(SUFFIX) \
		-e CFLAGS=$(CFLAGS) \
		-e LINKFLAGS=$(LINKFLAGS) \
		-e TARGET=$(TARGET) \
		$(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name)$(DOCKER_IMAGE_SUFFIX) \
		bash \
		-c "cd /tmp;bash ./tools-for-build/$(IMAGE)/setup;make $(DOCKER_ACTION)"

docker-default-action: compile archive

latest-uris:
	ros web.ros latests

latest-version:
	$(eval VERSION := $(shell ros web.ros version))
	$(eval BRANCH := $(shell VERSION=$(VERSION) ros build.ros branch))
	@echo "set version $(VERSION)"

upload-archive:
	VERSION=$(VERSION) TARGET=$(ARCH) SUFFIX=$(SUFFIX) ros web.ros upload-archive

upload-tsv:
	TSV_FILE=$(TSV_FILE) VERSION=$(VERSION) ros web.ros upload-tsv

download-tsv:
	VERSION=$(VERSION) ros web.ros get-tsv

table:
	ros web.ros table
# mirror
mirror-uris:
	curl -L http://sbcl.org/platform-table.html | grep http|awk -F '"' '{print $$2}'|grep binary > $@
tag:
	METHOD=mirror ros run -l Lakefile

precompile-freebsd:
	mv /usr/local/lib/libzstd.so* /tmp

postcompile-freebsd:
	mv /tmp/libzstd.so* /usr/local/lib
