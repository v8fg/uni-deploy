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
_default_repository=$(notdir $(_default_project_root))
_default_binary_name=uni_deploy_app
_default_tag=latest
_default_docker_file_name=Dockerfile
_default_docker_compose_file_name=docker-compose.yml

_docker_version=""
_compose_version=""

# The params will be override if specified by input
# SHOW_TIP whether or not show the init info
SHOW_TIP?=true

# PROJECT_ROOT the project root dir
PROJECT_ROOT?=${_default_project_root}
# BINARY_NAME the binary with the name, will run in the docker container
BINARY_NAME?=${_default_binary_name}

# hub related
REGISTRY?=
REGISTRY_ACCOUNT?=
REGISTRY_PASSWORD?=
REPOSITORY?=${_default_repository}
TAG?=${_default_tag}

IMAGE_ID?=
CONTAINER_ID?=

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

# check or override: BINARY_NAME
ifeq (,$(strip ${BINARY_NAME}))
	override BINARY_NAME=$(_default_binary_name)
$(warning [init] input param [BINARY_NAME=], change to [BINARY_NAME=${BINARY_NAME}])
endif

# check or override: REPOSITORY
ifeq (,$(strip ${REPOSITORY}))
	override REPOSITORY=$(_default_repository)
$(warning [init] input param [REPOSITORY=], change to [REPOSITORY=${REPOSITORY}])
endif

# check or override: TAG
ifeq (,$(strip ${TAG}))
	override TAG=$(_default_tag)
$(warning [init] input param [TAG=], change to [TAG=${TAG}])
endif

# if set, shall with path, absoulte better
DOCKER_FILE?=${PROJECT_ROOT}/${_default_docker_file_name}
# if set, shall with path, absoulte better
DOCKER_COMPOSE_FILE?=${PROJECT_ROOT}/${_default_docker_compose_file_name}

# check or override: DOCKER_FILE
ifeq (,$(strip ${DOCKER_FILE}))
	override DOCKER_FILE=${PROJECT_ROOT}/$(_default_docker_file_name)
$(warning [init] input param [DOCKER_FILE=], change to [TAG=${DOCKER_FILE}])
endif

# check or override: DOCKER_COMPOSE_FILE
ifeq (,$(strip ${DOCKER_COMPOSE_FILE}))
	override DOCKER_COMPOSE_FILE=${PROJECT_ROOT}/$(_default_docker_compose_file_name)
$(warning [init] input param [DOCKER_COMPOSE_FILE=], change to [DOCKER_COMPOSE_FILE=${DOCKER_COMPOSE_FILE}])
endif

# full image name: rerpository:tag
build_image_repository_name=${REPOSITORY}:${TAG}

_git_version=$(shell if [ -x $(command -v git) ]; then git --version | sed -En "s/([^0-9]*)([0-9\.]+)([^0-9]*.*)/\2/ p"; fi)
_docker_version=$(shell if [ -x $(command -v docker) ]; then docker --version | sed -En "s/([^0-9]*)([0-9\.]+)([^0-9]*.*)/\2/ p"; fi)
_compose_version=$(shell if [ -x $(command -v docker-compose) ]; then docker-compose --version | sed -En "s/([^0-9]*)([0-9\.]+)([^0-9]*.*)/\2/ p"; fi)

gitCommit=
gitCommitShort=
buildTime = $(shell date "+%FT%T%z")

# is git project
_is_git_project=$(shell cd ${PROJECT_ROOT}; if [ -d "./.git" ]; then git rev-parse --is-inside-work-tree; else echo "false"; fi)

ifeq (true,$(strip ${_is_git_project}))
	gitCommit=$(shell cd ${PROJECT_ROOT} && git rev-parse HEAD)
	gitCommitShort=$(shell cd ${PROJECT_ROOT} && git rev-parse --short HEAD)
endif

# only if SHOW_TIP=false, disable init info
ifneq (false,${SHOW_TIP})
$(info [init]	base:   [project_root=${PROJECT_ROOT}])
$(info [init]	vcs:   	[git=${_git_version}, commit_short=${gitCommitShort}, commit=${gitCommit}, inside_work_tree=${_is_git_project}])
$(info [init]	env:   	[docker=${_docker_version}, compose=${_compose_version}])
$(info [init]	base:   [ docker_file=${DOCKER_FILE}])
$(info [init]	base:   [compose_file=${DOCKER_COMPOSE_FILE}])
endif


# ----------- Makefile commands -----------
.PHONY: default help env cp-ignore \
	login login-auth build tag push list-image run run-daemon stop list-docker \
	rmi image-prune rm docker-prune compose-run compose-daemon compose-stop
	prune remove

default: help

## help:	prints this help message
help:
	@echo -e "${COLOR_USAGE}Usage:\n"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

## env:	print the docker and compose env
env:
	@echo -e "${COLOR_INFO}$(shell docker --version)${COLOR_RESET}"
	@echo -e "${COLOR_INFO}$(shell docker-compose --version)${COLOR_RESET}"
	@echo -e "[command-env]	${GREEN}execute success${COLOR_RESET}"

## login:	login docker-hub
login:
	docker login
	@echo -e "[command-login]	${GREEN}execute success${COLOR_RESET}"

## login-auth:	login docker-hub or the specied REGISTRY
login-auth:
	docker login -u "${REGISTRY_ACCOUNT}" "${REGISTRY}" -p "${REGISTRY_PASSWORD}"
	@echo -e "[command-login-auth]	${GREEN}execute success${COLOR_RESET}"
