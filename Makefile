#sbcl_bin
-include .env
export $(shell sed 's/=.*//' .env)

VERSION ?= $(shell ros build.ros version)
TSV_FILE ?= sbcl-bin_uri.tsv
WEB_ROS_URI=https://raw.githubusercontent.com/roswell/sbcl_bin/master/web.ros

BRANCH ?= $(shell ros build.ros branch)
VERSION_SUFFIX ?= .roswell
ARCH ?= $(shell ros build.ros uname)
SUFFIX ?=
TARGETS ?=$(ARCH)
SBCL_OPTIONS ?=--fancy
SBCL_PATCH ?=
LISP_IMPL ?= ros -L sbcl-bin without-roswell=t --no-rc run

DOCKER_REPO ?= docker.pkg.github.com/roswell/sbcl_bin
DOCKER_PLATFORM ?= linux/amd64
DOCKER_BUILD_OPTIONS ?=
DOCKER_IMAGE_SUFFIX ?=
IMAGE ?=
DOCKER_ACTION ?= bash ./tools-for-build/$(IMAGE)/setup;make docker-default-action

ZSTD_BRANCH ?= v1.5.6

#version
version: web.ros
	@echo $(shell ros web.ros version) > $@
branch: version
	$(eval VERSION := $(shell cat version))
	VERSION=$(VERSION) ros build.ros branch > $@
latest-uris: web.ros
	ros web.ros latests
web.ros:
	curl -L -O $(WEB_ROS_URI)
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
#tag
mirror-uris:
	curl -L http://sbcl.org/platform-table.html | grep http|awk -F '"' '{print $$2}'|grep binary > $@
tag:
	METHOD=mirror ros run -l Lakefile

clean:
	rm -rf zstd
	rm -f verson branch
	ls |grep sbcl |xargs rm -rf

show:
	@echo VERSION=$(VERSION) ARCH=$(ARCH) BRANCH=$(BRANCH) SUFFIX=$(SUFFIX)
	cc -x c -v -E /dev/null || true
	cc -print-search-dirs || true
sbcl:
	git clone --depth 5 https://github.com/sbcl/sbcl --branch=$(BRANCH)
	@if [ -n "$(SBCL_PATCH)" ]; then\
		SBCL_PATCH="$(SBCL_PATCH)" $(MAKE) patch-sbcl; \
	fi
zstd:
	git clone --depth 5 https://github.com/facebook/zstd --branch=$(ZSTD_BRANCH)

sbcl/version.lisp-expr: sbcl
	cd sbcl;echo '"$(VERSION)$(VERSION_SUFFIX)$(SUFFIX)"' > version.lisp-expr

compile-1: show sbcl
	cd sbcl;{ git describe  | sed -n -e 's/^.*-g//p' ; } 2>/dev/null > git_hash
	cat sbcl/git_hash
	rm -f sbcl/version.lisp-expr;VERSION=$(VERSION) $(MAKE) sbcl/version.lisp-expr
	mv sbcl/.git sbcl/_git
compile-config: compile-1
	cd sbcl;bash make-config.sh $(SBCL_OPTIONS) --arch=$(ARCH) --xc-host="$(LISP_IMPL)"
compile: compile-1
	bash -c "cd sbcl;bash make.sh $(SBCL_OPTIONS) --arch=$(ARCH) --xc-host='$(LISP_IMPL)' || mv _git .git" \
	&& $(MAKE) compile-9
compile-9:
	cd sbcl;bash make-shared-library.sh || true
	cd sbcl;bash run-sbcl.sh --eval "(progn (print *features*)(print (lisp-implementation-version))(terpri)(quit))"
	ldd sbcl/src/runtime/sbcl || \
	otool -L sbcl/src/runtime/sbcl || \
	readelf -d sbcl/src/runtime/sbcl || \
	true

archive:
	VERSION=$(VERSION) ARCH=$(ARCH) SUFFIX=$(SUFFIX) ros build.ros archive

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
	./tools-for-build/$(IMAGE)/pre-build || true
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
		$(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name)$(DOCKER_IMAGE_SUFFIX) \
		bash \
		-c "cd /tmp;$(DOCKER_ACTION)"

docker-default-action: compile archive

latest-version: version branch
	$(eval VERSION := $(shell cat version))
	$(eval BRANCH := $(shell cat branch))
	@echo "set version $(VERSION):$(BRANCH)"

precompile-freebsd:
	mv /usr/local/lib/libzstd.so* /tmp

postcompile-freebsd:
	mv /tmp/libzstd.so* /usr/local/lib

patch-sbcl:
	cd sbcl;git apply ../tools-for-build/patch/$(SBCL_PATCH);git diff
