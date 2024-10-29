#sbcl_bin
-include .env
export $(shell sed 's/=.*//' .env)

VERSION ?=
TSV_FILE ?= sbcl-bin_uri.tsv
ROS_URI=https://raw.githubusercontent.com/roswell/sbcl_bin/master/

ORIGIN_URI=https://github.com/sbcl/sbcl
ORIGIN_REF=master
GITHUB=https://github.com/$(GITHUB_REPOSITORY)

BRANCH ?= $(shell ros build.ros branch)
VERSION_SUFFIX ?= .roswell
ARCH ?= $(shell ros build.ros uname)
SUFFIX ?=
TARGETS ?=$(ARCH)
SBCL_OPTIONS ?=--fancy
SBCL_PATCH ?=
LISP_IMPL ?= ros -L sbcl-bin without-roswell=t --no-rc run

DOCKER_REPO ?= docker.pkg.github.com/$(GITHUB_REPOSITORY)
DOCKER_PLATFORM ?= linux/amd64
DOCKER_BUILD_OPTIONS ?=
DOCKER_IMAGE_SUFFIX ?=
IMAGE ?=
DOCKER_ACTION ?= bash ./tools-for-build/$(IMAGE)/setup;make docker-default-action

ZSTD_BRANCH ?= v1.5.6

#version
version: web.ros
	@echo $(shell GH_USER=$(GH_USER) GH_REPO=$(GH_REPO) ros web.ros version) > $@
branch: version build.ros
	$(eval VERSION := $(shell cat version))
	VERSION=$(VERSION) ros build.ros branch > $@
latest-uris: web.ros
	ros web.ros latests
web.ros:
	curl -L -O $(ROS_URI)/web.ros
build.ros:
	curl -L -O $(ROS_URI)/build.ros
#tsv
tsv: web.ros
	TSV_FILE=$(TSV_FILE) ros web.ros tsv
upload-tsv: web.ros
	TSV_FILE=$(TSV_FILE) VERSION=$(VERSION) ros web.ros upload-tsv
download-tsv: web.ros
	VERSION=$(VERSION) ros web.ros get-tsv
#table
table: web.ros
	ros web.ros table
#archive
upload-archive: web.ros
	VERSION=$(VERSION) TARGET=$(ARCH) SUFFIX=$(SUFFIX) ros web.ros upload-archive
upload-archive-p: web.ros
	VERSION=$(VERSION) TARGET=$(ARCH) SUFFIX=$(SUFFIX) ros web.ros upload-archive-p
archive: build.ros
	VERSION=$(VERSION) ARCH=$(ARCH) SUFFIX=$(SUFFIX) ros build.ros archive
#tag
mirror-uris:
	curl -L http://sbcl.org/platform-table.html | grep http|awk -F '"' '{print $$2}'|grep binary > $@
mirror:
	METHOD=mirror ros run -l Lakefile

hash:
	git ls-remote --heads $(ORIGIN_URI) $(ORIGIN_REF) |sed -r "s/^([0-9a-fA-F]*).*/\1/" > hash

lasthash:
	curl -sSL -f -o lasthash $(GITHUB)/releases/download/files/hash || rm -f lasthash

tag: hash lasthash web.ros
	@echo hash     = $(shell cat hash)
	@echo lasthash = $(shell cat lasthash)
	cp hash $(shell cat hash)
	diff -u hash lasthash || \
	( VERSION=$(VERSION) ros web.ros upload hash; \
	  VERSION=$(VERSION) ros web.ros upload $(shell cat hash); \
	  VERSION=files ros web.ros upload hash)

#zstd
zstd:
	git clone --depth 5 https://github.com/facebook/zstd --branch=$(ZSTD_BRANCH)

clean:
	rm -rf zstd
	rm -f verson branch
	ls |grep sbcl |xargs rm -rf
	rm -f hash lasthash

show:
	@echo VERSION=$(VERSION) ARCH=$(ARCH) BRANCH=$(BRANCH) SUFFIX=$(SUFFIX) HASH=$(HASH)
	cc -x c -v -E /dev/null || true
	cc -print-search-dirs || true

#sbcl
sbcl:
	@if [ -n "$(HASH)" ]; then \
		git clone --depth 100 $(ORIGIN_URI) --branch=$(ORIGIN_REF); \
		cd sbcl;git checkout $(HASH); \
	else \
		git clone --depth 5 $(ORIGIN_URI) --branch=$(BRANCH); \
	fi
	@if [ -n "$(SBCL_PATCH)" ]; then\
		SBCL_PATCH="$(SBCL_PATCH)" $(MAKE) patch-sbcl; \
	fi

sbcl/version.lisp-expr: sbcl
	cd sbcl;echo '"$(VERSION)$(VERSION_SUFFIX)$(SUFFIX)"' > version.lisp-expr

compile-1: show sbcl
	cd sbcl;{ git describe  | sed -n -e 's/^.*-g//p' ; } 2>/dev/null > git_hash
	cat sbcl/git_hash
	rm -f sbcl/version.lisp-expr;VERSION=$(VERSION) $(MAKE) sbcl/version.lisp-expr
	mv sbcl/.git sbcl/_git || true
compile-config: compile-1
	cd sbcl;bash make-config.sh $(SBCL_OPTIONS) --arch=$(ARCH) --xc-host="$(LISP_IMPL)"
compile: compile-1
	bash -c "cd sbcl;bash make.sh $(SBCL_OPTIONS) --arch=$(ARCH) --xc-host='$(LISP_IMPL)'" \
	&& $(MAKE) compile-9
compile-9:
	cd sbcl;mv _git .git || true
	cd sbcl;bash make-shared-library.sh || true
	cd sbcl;bash run-sbcl.sh --eval "(progn (print *features*)(print (lisp-implementation-version))(terpri)(quit))"
	ldd sbcl/src/runtime/sbcl || \
	otool -L sbcl/src/runtime/sbcl || \
	readelf -d sbcl/src/runtime/sbcl || \
	true
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
	DOCKER_PLATFORM=$(DOCKER_PLATFORM) sh ./tools-for-build/$(IMAGE)/pre-build || true
	docker build --platform $(DOCKER_PLATFORM) -t $(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name)$(DOCKER_IMAGE_SUFFIX) $(DOCKER_BUILD_OPTIONS) ./tools-for-build/$(IMAGE)
push-docker:
	docker push $(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name)$(DOCKER_IMAGE_SUFFIX);
pull-docker:
	docker pull $(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name)$(DOCKER_IMAGE_SUFFIX);
docker:
	docker run \
		--rm \
		--platform $(DOCKER_PLATFORM) \
		-v `pwd`:/tmp \
		-e ARCH=$(ARCH) \
		-e VERSION=$(VERSION) \
		-e SUFFIX=$(SUFFIX) \
		-e CFLAGS=$(CFLAGS) \
		-e LINKFLAGS=$(LINKFLAGS) \
		-e TARGET=$(TARGET) \
		-e LISP_IMPL="$(LISP_IMPL)" \
		$(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name)$(DOCKER_IMAGE_SUFFIX) \
		bash \
		-c "cd /tmp;$(DOCKER_ACTION)"
#OK
#TARGET=riscv64 DOCKER_PLATFORM=linux/riscv64 DOCKER_IMAGE_SUFFIX=riscv64 IMAGE=glibc2.31          SUFFIX= make cross-docker
#NG
#TARGET=armhf   DOCKER_PLATFORM=linux/arm/v6  DOCKER_IMAGE_SUFFIX=armhf   IMAGE=glibc2.13-raspbian SUFFIX=-glibc2.13 LINKFLAGS=-lrt  make cross-docker

cross-docker: cross-docker-1 cross-docker-2 cross-docker-3 cross-docker-4 cross-docker-5
	OS=linux ARCH=$(TARGET) SUFFIX=$(SUFFIX) make latest-version archive

cross-docker-1:
	IMAGE=$(IMAGE) \
	TARGET=$(TARGET) \
	SUFFIX=$(SUFFIX) \
	CFLAGS=$(CFLAGS) \
	LINKFLAGS=$(LINKFLAGS) \
	DOCKER_PLATFORM=$(DOCKER_PLATFORM) \
	DOCKER_IMAGE_SUFFIX=$(DOCKER_IMAGE_SUFFIX) \
	DOCKER_ACTION="bash ./tools-for-build/$(IMAGE)/setup;make latest-version compile-config" \
	ARCH="" \
	$(MAKE) latest-version docker

cross-docker-2:
	cd sbcl;sh make-host-1.sh

cross-docker-3:
	IMAGE=$(IMAGE) \
	TARGET=$(TARGET) \
	SUFFIX=$(SUFFIX) \
	CFLAGS=$(CFLAGS) \
	LINKFLAGS=$(LINKFLAGS) \
	DOCKER_PLATFORM=$(DOCKER_PLATFORM) \
	DOCKER_IMAGE_SUFFIX=$(DOCKER_IMAGE_SUFFIX) \
	DOCKER_ACTION="bash ./tools-for-build/$(IMAGE)/setup;cd sbcl;sh make-target-1.sh" \
	$(MAKE) latest-version docker

cross-docker-4:
	cd sbcl;sh make-host-2.sh

cross-docker-5:
	IMAGE=$(IMAGE) \
	SUFFIX=$(SUFFIX) \
	CFLAGS=$(CFLAGS) \
	LINKFLAGS=$(LINKFLAGS) \
	DOCKER_PLATFORM=$(DOCKER_PLATFORM) \
	DOCKER_IMAGE_SUFFIX=$(DOCKER_IMAGE_SUFFIX) \
	DOCKER_ACTION="bash ./tools-for-build/$(IMAGE)/setup;cd sbcl;sh make-target-2.sh && sh make-target-contrib.sh;cd ..;make latest-version compile-9" \
	$(MAKE) latest-version docker

docker-default-action: compile archive

latest-version: version branch lasthash
	$(eval VERSION := $(shell cat version))
	$(eval BRANCH := $(shell cat branch))
	$(eval HASH := $(shell cat lasthash))
	@echo "set version $(VERSION):$(HASH):$(BRANCH)"

precompile-freebsd:
	mv /usr/local/lib/libzstd.so* /tmp

postcompile-freebsd:
	mv /tmp/libzstd.so* /usr/local/lib

patch-sbcl:
	cd sbcl;git apply ../tools-for-build/patch/$(SBCL_PATCH);git diff
