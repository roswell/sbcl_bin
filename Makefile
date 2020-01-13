NOP := $(shell ros build.ros nop) # avoid messages compile.
BRANCH ?= $(shell ros build.ros branch)
VERSION ?= $(shell ros build.ros version)
ARCH ?= $(shell ros build.ros uname)
SUFFIX ?=
TARGETS ?=$(ARCH)
SBCL_OPTIONS ?=--with-sb-core-compression
compile:
	echo VERSION=$(VERSION) ARCH=$(ARCH) BRANCH=$(BRANCH)
	rm -rf sbcl
	git clone --depth 5 https://github.com/sbcl/sbcl --branch=$(BRANCH) || git clone --depth 5 https://git.code.sf.net/p/sbcl/sbcl --branch=$(BRANCH)
	cd sbcl;rm -rf .git
	cd sbcl;echo '"$(VERSION)"' > version.lisp-expr
	cd sbcl;bash make.sh $(SBCL_OPTIONS) --arch=$(ARCH) "--xc-host=ros -L sbcl-bin without-roswell=t --no-rc run"
	cd sbcl;bash run-sbcl.sh --eval "(progn (print *features*)(terpri)(quit))"

archive:
	VERSION=$(VERSION) ARCH=$(ARCH) BRANCH=$(BRANCH) make compile
	VERSION=$(VERSION) ARCH=$(ARCH) SUFFIX=$(SUFFIX) ros build.ros archive
	echo VERSION=$(VERSION) ARCH=$(ARCH) BRANCH=$(BRANCH) SUFFIX=$(SUFFIX)

archives:
	for ar in $(TARGETS); do \
	  VERSION=$(VERSION) ARCH=$$ar BRANCH=$(BRANCH) SUFFIX=$(SUFFIX) make archive; \
	done

docker:
	docker run \
		-v `pwd`:/tmp \
		-e ARCH=$(ARCH) \
		-e VERSION=$(VERSION) \
		-e BRANCH=$(BRANCH) \
		-e SUFFIX=$(SUFFIX) \
		-e "TARGETS=$(TARGETS)" \
		-it $$DOCKER bash \
		-c "cd /tmp;make multi-archive"
