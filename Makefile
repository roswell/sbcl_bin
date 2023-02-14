-include .env
export $(shell sed 's/=.*//' .env)

NOP := $(shell ros build.ros nop) # avoid messages compile.
BRANCH ?= $(shell ros build.ros branch)
VERSION ?= $(shell ros build.ros version)
ARCH ?= $(shell ros build.ros uname)
SUFFIX ?=
TARGETS ?=$(ARCH)
SBCL_OPTIONS ?=--with-sb-core-compression
LISP_IMPL ?= ros -L sbcl-bin without-roswell=t --no-rc run
DOCKER_REPO ?= docker.pkg.github.com/roswell/sbcl_bin

show:
	@echo VERSION=$(VERSION) ARCH=$(ARCH) BRANCH=$(BRANCH) SUFFIX=$(SUFFIX)

compile: show
	rm -rf sbcl
	git clone --depth 5 https://github.com/sbcl/sbcl --branch=$(BRANCH) || git clone --depth 5 https://git.code.sf.net/p/sbcl/sbcl --branch=$(BRANCH)
	cd sbcl;{ git describe  | sed -n -e 's/^.*-g//p' ; } 2>/dev/null > git_hash
	cat sbcl/git_hash
	cd sbcl;rm -rf .git
	cd sbcl;echo '"$(VERSION)"' > version.lisp-expr
	cd sbcl;bash make.sh $(SBCL_OPTIONS) --arch=$(ARCH) --xc-host="$(LISP_IMPL)" || true
	cd sbcl;bash run-sbcl.sh --eval "(progn (print *features*)(terpri)(quit))"

archive:
	VERSION=$(VERSION) ARCH=$(ARCH) SUFFIX=$(SUFFIX) ros build.ros archive

tsv:
	ros web.ros tsv

build-docker:
	docker build -t $(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name) ./tools-for-build/$(IMAGE)
push-docker:
	docker push $(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name);
pull-docker:
	docker pull $(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name);
docker:
	docker run \
		-v `pwd`:/tmp \
		-e ARCH=$(ARCH) \
		-e VERSION=$(VERSION) \
		-e BRANCH=$(BRANCH) \
		-e SUFFIX=$(SUFFIX) \
		-e CFLAGS=$(CFLAGS) \
		-e LINKFLAGS=$(LINKFLAGS) \
		-e TARGET=$(TARGET) \
		$(DOCKER_REPO)/$$(cat ./tools-for-build/$(IMAGE)/Name) \
		bash \
		-c "cd /tmp;make compile archive"

latest-uris:
	ros web.ros latests

latest-version:
	$(eval VERSION := $(shell ros web.ros version))
	$(eval BRANCH := $(shell VERSION=$(VERSION) ros build.ros branch))
	@echo "set version $(VERSION)"

upload-archive: show
	VERSION=$(VERSION) TARGET=$(ARCH) SUFFIX=$(SUFFIX) ros web.ros upload-archive

upload-tsv:
	VERSION=$(VERSION) TARGET=$(ARCH) SUFFIX=$(SUFFIX) ros web.ros upload-tsv

download-tsv:
	VERSION=$(VERSION) ros web.ros get-tsv

table:
	ros build.ros table
