# Makefile to build the command lines and tests in this project.
# This Makefile doesn't consider Windows Environment. If you use it in Windows, please be careful.
SHELL := /bin/sh

# -------- color constant start -------
RED=\033[31;01m
GREEN=\033[32;01m
YELLOW=\033[33;01m
BLUE=\033[34;01m
PURPLE=\033[35;01m
DARK_GREEN=\033[36;01m
WHITE=\033[37;01m
COLOR_RESET=\033[0m
COLOR_USAGE=${RED}
COLOR_DEBUG=${WHITE}
COLOR_INFO=${BLUE}
COLOR_OK=${GREEN_COLOR}
COLOR_ERROR=${RED_COLOR}
# -------- color constant end -------

existBash = $(shell cat /etc/shells|grep -w /bin/bash|grep -v grep)
ifneq (, $(strip ${existBash}))
	SHELL = /bin/bash
endif
$(info [init]	shell will use '${SHELL}' (bash preffered, support 5.0+))

# some default inner params
_current_script_dir=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))
_default_project_root=$(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST))))../..)
_default_binary_name=uni_deploy_app
_default_build_dir_out=${_default_project_root}/build

# CGO_ENABLED default=0, CGO_ENABLED=1 smaller binary but need host os c lib
# Warn: shall not set CGO_ENABLED=1 if deploy or release
CGO_ENABLED?=0

# The params will be override if specified by input
# SHOW_TIP whether or not show the init info
SHOW_TIP?=true

# PROJECT_ROOT the project root dir
PROJECT_ROOT?=${_default_project_root}

# BUILD_DIR_OUT the project build output dir
BUILD_DIR_OUT?=${_default_build_dir_out}

# BINARY_NAME the binary name, output binary will use
BINARY_NAME?=${_default_binary_name}

ifeq (1,$(strip ${CGO_ENABLED}))
	override CGO_ENABLED=1
$(warning [init] input param [CGO_ENABLED=], change to [CGO_ENABLED=${CGO_ENABLED}])
endif

# check or override: SHOW_TIP
ifeq (,$(strip ${SHOW_TIP}))
	override SHOW_TIP=false
$(warning [init] input param [SHOW_TIP=], change to [SHOW_TIP=${SHOW_TIP}])
endif

# check or override: PROJECT_ROOT
ifeq (,$(strip ${PROJECT_ROOT}))
	override PROJECT_ROOT=$(_default_project_root)
$(warning [init] input param [PROJECT_ROOT=], change to [PROJECT_ROOT=${PROJECT_ROOT}])
endif

# check or override: BUILD_DIR_OUT
ifeq (,$(strip ${BUILD_DIR_OUT}))
	override BUILD_DIR_OUT=$(_default_build_dir_out)
$(warning [init] input param [BUILD_DIR_OUT=], change to [BUILD_DIR_OUT=${BUILD_DIR_OUT}])
endif

# check or override: BINARY_NAME
ifeq (,$(strip ${BINARY_NAME}))
	override BINARY_NAME=${_default_binary_name}
$(warning input param [BINARY_NAME=], change to [BINARY_NAME=${BINARY_NAME}])
endif

# the specified filename, with absolute path, for generate binary; pls add it to your .gitignore
binary_file=${BUILD_DIR_OUT}/bin/${BINARY_NAME}

# the dir, absolute path for generate binaries
build_dir_out_binary=${BUILD_DIR_OUT}/bin

# the dir, absolute path for generate conf
build_dir_out_conf=${BUILD_DIR_OUT}/conf

# the dir, absolute path for generate coverage
build_dir_out_coverage=${BUILD_DIR_OUT}/coverage

# generate all dirs will be used
$(shell mkdir -p ${build_dir_out_conf} ${build_dir_out_binary} ${build_dir_out_coverage})

# only if SHOW_TIP=false, disable init info
ifneq (false,${SHOW_TIP})
$(info [init]	env:   	[go_verion=$(shell go version), CGO_ENABLED=${CGO_ENABLED}])
$(info [init]	base:   [binary_name=${BINARY_NAME}, project_root=${PROJECT_ROOT}])
$(info [init]	output: [build_out_dir=${BUILD_DIR_OUT}])
$(info [init]	output: [binary output=${binary_file})
$(info [init]	output: [conf   output=${build_dir_out_conf}])
endif

# ----------- go pkg and files -----------
PACKAGES=$(shell cd ${PROJECT_ROOT} && go list ./... | grep -v /vendor/)
VET_PACKAGES=$(shell cd ${PROJECT_ROOT} && go list ./... | grep -v /vendor/ | grep -v /examples/)
GO_FILES=$(shell cd ${PROJECT_ROOT} && find . -name "*.go" -type f -not -path "./vendor/*")
# GO_FILES=$(shell cd ${PROJECT_ROOT} && find . -name "*.go" | grep -v "./vendor/")
# GO_FILES=$(shell cd ${PROJECT_ROOT} && find . -name "*.go" -type f -not -path "./vendor/*" | grep -v _test.go)

# ----------- build version params with git -----------
# add following lines before go build!
versionDir = github.com/xwi88/version

buildTime = $(shell date "+%FT%T%z")
gitCommit = $(shell cd ${PROJECT_ROOT} && git rev-parse HEAD)
gitCommitShort = $(shell cd ${PROJECT_ROOT} && git rev-parse --short HEAD)
gitTreeState = $(shell cd ${PROJECT_ROOT} && (if git status|grep -q 'clean';then echo clean; else echo dirty; fi))
gitBranch = $(shell cd ${PROJECT_ROOT} && git symbolic-ref --short -q HEAD)

ifeq (,$(strip $(gitBranch)))
	gitTag = $(shell cd ${PROJECT_ROOT} && git describe --always --tags --abbrev=0)
endif

# ----------- build version params with go ldflags -----------
# ldflags: stands for linker flags. It passes a flag to the underlying Go toolchain linker, cmd/link, that allows you to change the values of imported packages at build time from the command line.
# more ref: https://pkg.go.dev/cmd/link
# -s Omit the symbol table and debug information. -w Omit the DWARF symbol table.
# -s -w: build command removes the information your debugger requires for debugging
# tip: if need debug or catch trace detail, shall not remove that

ldFlagsDebug="-X ${versionDir}.gitBranch=${gitBranch} -X ${versionDir}.gitTag=${gitTag} \
-X ${versionDir}.buildTime=${buildTime} -X ${versionDir}.gitCommit=${gitCommit} \
-X ${versionDir}.gitTreeState=${gitTreeState}"

ldFlagsRelease="-s -w -X ${versionDir}.gitBranch=${gitBranch} -X ${versionDir}.gitTag=${gitTag} \
-X ${versionDir}.buildTime=${buildTime} -X ${versionDir}.gitCommit=${gitCommit} \
-X ${versionDir}.gitTreeState=${gitTreeState}"

# ----------- build version params with go tags -----------
buildTags="jsoniter"

# ----------- Makefile commands -----------
.PHONY: default help env vet lint list tidy vendor go-clean go-version\
	fmt fmt-check fmt-check-files fmt-check-changes \
	test cover cover-html cover-func race  \
	build build-darwin build-linux release release-vendor list-build \
	upx upx-bak upx-binaries binary-bak \
	version run run-binary \
	clean clean-binary clean-conf

default: help

## help:	prints this help message
help:
	@echo -e "${COLOR_USAGE}Usage:\n"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

## env:	print the go env
env:
	@echo -e "${COLOR_INFO}$(shell go env)${COLOR_RESET}"
	@echo -e "[command-env]	${GREEN}execute success${COLOR_RESET}"

## vet:	vet check, more pls ref, go help vet
vet:
	@echo -e "[command-vet]	${RED}executing vet${COLOR_RESET}"
	@cd ${PROJECT_ROOT} && go vet $(VET_PACKAGES)
	@echo -e "[command-vet]	${GREEN}execute success${COLOR_RESET}"

## lint:	golangci lint, now incompatible with go1.18
lint:
	@cd ${PROJECT_ROOT} && golangci-lint cache clean && \
	golangci-lint run -c ${_current_script_dir}/golangci.yml ./...
	@echo -e "[command-lint]	${GREEN}execute success${COLOR_RESET}"

## list:	list all your packages, vet packages, go files
list:
	@echo -e "${RED}PACKAGES:${COLOR_RESET}\n${PACKAGES}\n"
	@echo -e "${YELLOW}VET_PACKAGES:${COLOR_RESET}\n${VET_PACKAGES}\n"
	@echo -e "${BLUE}GO_FILES:${COLOR_RESET}\n${GO_FILES}\n"
	@echo -e "[command-list]	${GREEN}execute success"

## tidy:	go mod tidy, update go.mod
tidy:
	@cd ${PROJECT_ROOT} && go mod tidy -v
	@echo -e "[command-tidy]	${GREEN}execute success"

## vendor:	update or created vendor directory for your packages
vendor:
	@cd ${PROJECT_ROOT} && \
	go mod tidy -v && go mod vendor -o ${PROJECT_ROOT}/vendor
	@echo -e "[command-vendor]	${GREEN}execute success"

## go-clean:	go clean
go-clean:
	@cd ${PROJECT_ROOT} && go clean -v
	@echo -e "[command-go-clean]	${GREEN}execute success"

## go-version:	go version
go-version:
	@go version
	@echo -e "[command-go-version]	${GREEN}execute success"

## fmt:	format the go files with gofmt
fmt:
	@cd ${PROJECT_ROOT} && gofmt -s -w ${GO_FILES}
	@echo -e "[command-fmt]	${GREEN}execute success${COLOR_RESET}"

## fmt-check:	check whether or not shall format the go files
fmt-check:
	@cd ${PROJECT_ROOT} && diffs=$$(gofmt -l ${GO_FILES}); \
	if [[ -n "$$diffs" ]]; then \
		echo -e "${RED}Pls run 'make fmt' and commit the result:${COLOR_RESET}"; \
		echo -e "[command-fmt-check]	${PURPLE}gofmt diff files:${COLOR_RESET}\n${BLUE}$${diffs}${COLOR_RESET}"; \
		echo -e "${RED}Pls run 'make fmt' and commit the result:${COLOR_RESET}"; \
		exit 1; \
    else	\
		echo -e "[command-fmt-check]	${GREEN}gofmt no diff files${COLOR_RESET}"; \
		exit 0; \
    fi; \

## fmt-check-files:	check the diff files with gofmt
fmt-check-files:
	@cd ${PROJECT_ROOT} && gofmt -l ${GO_FILES}
	@echo -e "[command-fmt-check-files]	${GREEN}execute success${COLOR_RESET}"

## fmt-check-changes:	check the diffs of files with gofmt
fmt-check-changes:
	@cd ${PROJECT_ROOT} && gofmt -d -s ${GO_FILES}
	@echo -e "[command-fmt-check-changes] ${GREEN}execute success${COLOR_RESET}"

## test:	go test
test:
	@cd ${PROJECT_ROOT} && \
	go test -cpu=1,2,4 -v -tags integration ./...
	@echo -e "[command-test]	${GREEN}execute success"

# cover:	generate coverage data, more, 'go tool cover -help'
cover:
	@cd ${PROJECT_ROOT} && \
	go test ./... -coverprofile=${build_dir_out_coverage}/coverage.out -covermode=atomic
	@echo -e "[command-cover]	${GREEN}execute success"

# cover-html:	generate coverage report, format html
cover-html:
	@cd ${PROJECT_ROOT} && \
	go tool cover -html=${build_dir_out_coverage}/coverage.out -o ${build_dir_out_coverage}/coverage.html
	@echo -e "[command-cover-html]	${GREEN}execute success"

# cover-func:	generate coverage report, func
cover-func:
	@cd ${PROJECT_ROOT} && \
	go tool cover -func=${build_dir_out_coverage}/coverage.out -o ${build_dir_out_coverage}/coverage_func.txt
	@echo -e "[command-cover-func]	${GREEN}execute success"

race:
	cd ${PROJECT_ROOT} && \
	go run -race ${PROJECT_ROOT}/main.go start

## build:	go build with tags and ldflags, mainly for dev
build: go-clean
	@echo -e "${COLOR_INFO}"
	@cd ${PROJECT_ROOT} && \
	go build -v -tags ${buildTags} -ldflags ${ldFlagsDebug} -o ${binary_file} ${PROJECT_ROOT}
	@echo -e "[command-build]	${GREEN}build output binary: ${binary_file}"

## build-darwin:	cross-platform build use, issues with tensorflow, shall support dynamic cgo, goos, goarch setting
build-darwin:
	@echo -e "${COLOR_INFO}"
	@cd ${PROJECT_ROOT} && \
	export CGO_ENABLED=${CGO_ENABLED} && export GOOS=darwin && export GOARCH=amd64 && \
	go build -v -tags ${buildTags} -ldflags ${ldFlagsRelease} -o ${binary_file}-darwin ${PROJECT_ROOT}
	@echo -e "[command-build-darwin]	${GREEN}build output binary: ${binary_file}-darwin"

## build-linux:	cross-platform build use, issues with tensorflow, shall support dynamic cgo, goos, goarch setting
build-linux:
	@echo -e "${COLOR_INFO}"
	@cd ${PROJECT_ROOT} && \
	export CGO_ENABLED=${CGO_ENABLED} && export GOOS=linux && export GOARCH=amd64 && \
	go build -v -tags ${buildTags} -ldflags ${ldFlagsRelease} -o ${binary_file}-linux ${PROJECT_ROOT}
	@echo -e "[command-build-linux]	${GREEN}build output binary: ${binary_file}-linux"

## release:	release binary, build with go mod
release:
	@echo -e "${COLOR_INFO}"
	@cd ${PROJECT_ROOT} && \
	go build -v -mod=mod -tags ${buildTags} -ldflags ${ldFlagsRelease} -o ${binary_file} ${PROJECT_ROOT}
	@echo -e "[command-release]	${GREEN}build output binary: ${binary_file}"

## release-vendor:	release binary, build with go vendor
release-vendor:
	@echo -e "${COLOR_INFO}"
	@cd ${PROJECT_ROOT} && go mod vendor && \
	go build -v -mod=vendor -tags ${buildTags} -ldflags ${ldFlagsRelease} -o ${binary_file} ${PROJECT_ROOT}
	@echo -e "[command-release-vendor]	${GREEN}build output binary: ${binary_file}"

## upx:	upx compress binary specify
upx:
	@ls -lhr ${build_dir_out_binary}/*
	@echo -e "[command-upx]	${BLUE}execute upx start${COLOR_RESET}"
	@rm -f ${binary_file}-upx
	@upx -q ${binary_file} -o ${binary_file}-upx
	@echo -e "[command-upx]	${GREEN}execute upx  end${COLOR_RESET}"
	@ls -lhr ${build_dir_out_binary}/*
	@echo -e "[command-upx]	${GREEN}execute success${COLOR_RESET}"

## upx-bak:	upx compress binary specify and backup the binary
upx-bak: binary-bak upx
	@cp ${binary_file} ${binary_file}-bak
	@echo -e "[command-upx-bak]	${GREEN}execute success${COLOR_RESET}"

## upx-binaries:	upx compress binaries in the build_dir_out_binary
upx-binaries:
	@ls -lhr ${build_dir_out_binary}/*
	@echo -e "[command-upx-binaries]	${BLUE}execute upx start${COLOR_RESET}"
	@upx ${build_dir_out_binary}/*
	@echo -e "[command-upx-binaries]	${GREEN}execute upx  end${COLOR_RESET}"
	@ls -lhr ${build_dir_out_binary}/*
	@echo -e "[command-upx-binaries]	${GREEN}execute success${COLOR_RESET}"

# binary bak for upx backup the origin binary
binary-bak:
	@cp ${binary_file} ${binary_file}-bak
	@echo -e "[binary-bak]	${GREEN}backup file ${binary_file} to ${binary_file}-bak success${COLOR_RESET}"

## list-build:	list files in build dir
list-build:
	@echo -e "[command-list-build]	${BLUE}list files in build dir${COLOR_RESET}"
	@ls -lh ${BUILD_DIR_OUT}
	@echo -e "[command-list-build]	${YELLOW}list files in build bin${COLOR_RESET}"
	@ls -lh ${build_dir_out_binary}
	@echo -e "[command-list-build]	${RED}list files in build conf${COLOR_RESET}"
	@ls -lh ${build_dir_out_conf}
	@echo -e "[command-list-build]	${GREEN}execute success"

## run:	build the binary and run
run: build run-binary
	@echo -e "[command-run]	${GREEN}execute success"

## run-binary:	run the binary specify
run-binary:
	@cd ${PROJECT_ROOT} && ${binary_file} start
	@echo -e "[command-binary]	${GREEN}execute success"

## clean:	clean the build output dir
clean:
	@cd ${BUILD_DIR_OUT} && \
	if [ -d ${BUILD_DIR_OUT} ] ; then rm -rf ${BUILD_DIR_OUT} ; fi
	@echo -e "[command-clean]	${GREEN}clean ${BUILD_DIR_OUT} success"

## clean-binary:	only clean the build binary specify
clean-binary:
	@cd ${BUILD_DIR_OUT} && \
	if [ -f ${binary_file} ] ; then rm ${binary_file} ; fi
	@echo -e "[command-clean-binary]	${GREEN}clean ${binary_file} success"

## clean-conf:	only clean the build conf
clean-conf:
	@cd ${BUILD_DIR_OUT} && \
	if [ -f ${build_dir_out_conf} ] ; then rm ${build_dir_out_conf} ; fi
	@echo -e "[command-clean-conf]	${GREEN}clean ${build_dir_out_conf} success"

## version:	print the binary app version, need third pkg
version:
	${binary_file} version
	@echo -e "[command-version]	${GREEN}execute success"
