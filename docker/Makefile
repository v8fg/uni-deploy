# Makefile to build the command lines and tests in this project.
# This Makefile doesn't consider Windows Environment. If you use it in Windows, please be careful.
SHELL := /bin/sh

define NEWLINE

endef

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
SHOW_TIP?=false
override CURRENT_SCRIPT_DIR=${_current_script_dir}

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
# NEW_REPOSITORY format shall like: ${REGISTRY}/${NAMESPACE}/${IMAGE_NAME}[-${PUSH_TIME}]
NEW_REPOSITORY?=

# image id
IMAGE_ID?=
# container id
CONTAINER_ID?=
# display logs count, default 200
LOGS_COUNT?=200

# for image list filter, format: -f reference=""
IMAGE_LIST_PARAMS?=-f reference=""

CONTAINER_LIST_PARAMS?=

COMPOSE_RUN_PARAMS?="-d"

# for run container, the image(name or id) use
CONTAINER_IMAGE?=${REPOSITORY}:${TAG}
# for run container, container name, format: --name <container_name>
CONTAINER_NAME_PARAM?=
# for run container, format like: -d daemon -v v1:v1 ... -p p1:p2 ... -e k1=v1 ...
CONTAINER_PARAMS?=
# for run container, params for app need, container CMD need
CONTAINER_CMD_PARAMS?=

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

# if set, shall with path, absolute better
DOCKER_FILE?=${PROJECT_ROOT}/${_default_docker_file_name}
# if set, shall with path, absolute better
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

# full image name: repository:tag
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
$(info ${NEWLINE})
endif


# ----------- Makefile commands -----------
.PHONY: default help env cp-ignore \
	login login-auth build tag push list-image list-docker\
	once-tag once-push \
	run stop \
	rmi image-prune rm docker-prune compose-run compose-stop \
	logs

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

## cp-ignore:	copy the default '.dockerignore' file to the root dir of your project, pls rename it manually
cp-ignore:
	cp ${CURRENT_SCRIPT_DIR}/.dockerignore-example ${PROJECT_ROOT}
	@echo -e "[command-cp-ignore]	${GREEN}execute success${COLOR_RESET}"

## login:	login docker-hub
login:
	docker login
	@echo -e "[command-login]	${GREEN}execute success${COLOR_RESET}"

## login-auth:	login docker-hub or the special REGISTRY
login-auth:
	docker login -u "${REGISTRY_ACCOUNT}" "${REGISTRY}" -p "${REGISTRY_PASSWORD}"
	@echo -e "[command-login-auth]	${GREEN}execute success${COLOR_RESET}"

## build:	docker build with REPOSITORY(default your dir name) and TAG(default latest)
build:
	@echo -e "building image with name:[${REPOSITORY}:${TAG}], use Dockerfile:${DOCKER_FILE}"
	@cd ${PROJECT_ROOT} && docker build -t ${REPOSITORY}:${TAG} -f ${DOCKER_FILE} .
	@echo -e "build image with name:[${REPOSITORY}:${TAG}], use Dockerfile:${DOCKER_FILE}"
	@echo -e "[command-build]	${GREEN}execute success${COLOR_RESET}"

## tag:	docker tag, only support rename tag by image id
tag:
	@docker tag ${IMAGE_ID} ${REPOSITORY}:${TAG}
	@echo -e "[command-tag]	${GREEN}image with ID [${IMAGE_ID}], rename to [${REPOSITORY}:${TAG}${COLOR_RESET}]"
	@echo -e "[command-tag]	${GREEN}execute success${COLOR_RESET}"

## push:	push docker images to docker hub or others. shall login before push!
push:
	docker push ${REPOSITORY}:${TAG}
	@echo -e "[command-push]	${GREEN}push ${REPOSITORY}:${TAG} over${COLOR_RESET}"

## once-tag: docker tag, rename old to the specified tag
once-tag:
	@docker tag ${REPOSITORY}:${TAG} ${NEW_REPOSITORY}
	@echo -e "[command-once-tag]	${GREEN}image [${REPOSITORY}:${TAG} ], rename to [${NEW_REPOSITORY}${COLOR_RESET}]"
	@echo -e "[command-once-tag]	${GREEN}execute success${COLOR_RESET}"

## once-push:	push docker images with the specified tag to docker hub or others. shall login before push!
once-push:
	docker push ${NEW_REPOSITORY}
	@echo -e "[command-once-push]	${GREEN}push ${NEW_REPOSITORY} over${COLOR_RESET}"

## list-image:	list docker images, can with filter, -f reference="", ref 'docker images --help'
list-image:
	@docker images ${IMAGE_LIST_PARAMS}
	@echo -e "[command-list-image]	${GREEN}list all images, with params:[${IMAGE_LIST_PARAMS}]${COLOR_RESET}"

## list-docker:	list docker container, can with filter, ref 'docker ps --help' or 'docker container ls --help'
list-docker:
	@docker ps ${CONTAINER_LIST_PARAMS}
	@echo -e "[command-list-docker]	${GREEN}list containers with params:[${CONTAINER_LIST_PARAMS}]${COLOR_RESET}"

## run:	docker run with specified params, must set 'CONTAINER_IMAGE', format(image name or id)
run:
	@echo -e "[command-run]	${GREEN}run docker, with container image:[${CONTAINER_IMAGE}]${COLOR_RESET}"
	docker run -it ${CONTAINER_NAME_PARAM} --rm ${CONTAINER_PARAMS} ${CONTAINER_IMAGE} ${CONTAINER_CMD_PARAMS}

## stop:	stop the running containers with container ids
stop:
	docker stop ${CONTAINER_ID}
	@echo -e "[command-stop]	${GREEN}stop container, with container id:[${CONTAINER_ID}]${COLOR_RESET}"

## rmi:	remove the images with image ids
rmi:
	docker rmi ${IMAGE_ID}
	@echo -e "[command-rmi]	${GREEN}remove images :[${IMAGE_ID}]${COLOR_RESET}"

## image-prune:	remove all unused images, ref docker image --help
image-prune:
	docker image prune
	@echo -e "[command-image-prune]	${GREEN}remove all unused images${COLOR_RESET}"

## rm:	remove the containers with container ids
rm:
	docker rm ${CONTAIN_ID}
	@echo -e "[command-rm]	${GREEN}remove containers :[${CONTAIN_ID}]${COLOR_RESET}"

## docker-prune:	remove all stopped containers, ref docker container --help
docker-prune:
	docker image prune
	@echo -e "[command-docker-prune]	${GREEN}remove all stopped containers${COLOR_RESET}"

compose-run:
	@echo -e "[command-compose-run]	${GREEN}docker-compose run with file:[${DOCKER_COMPOSE_FILE}]${COLOR_RESET}"
	docker-compose -f ${DOCKER_COMPOSE_FILE} up ${COMPOSE_RUN_PARAMS}

compose-stop:
	@echo -e "[command-compose-stop]	${GREEN}docker-compose stop with file:[${DOCKER_COMPOSE_FILE}]${COLOR_RESET}"
	docker-compose -f ${DOCKER_COMPOSE_FILE} stop

logs:
	docker logs -fn ${LOGS_COUNT} ${CONTAINER_ID}
	@echo -e "[command-logs]	${GREEN}the latest ${LOGS_COUNT} logs, for container_id:${CONTAINER_ID}${COLOR_RESET}"

compose-logs:
	docker-compose logs
	@echo -e "[command-compose-logs]	${GREEN}execute success${COLOR_RESET}"
