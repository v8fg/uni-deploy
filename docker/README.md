# uni-deploy docker

## requirements

>pls ref: [docker requirements](../README.md)

## usage

- `make help` _if already in the `uni-deploy/docker`_
- `cd {PROJECT_ROOT}/uni-deploy/docker && make [command]`
- `make -C {PROJECT_ROOT}/uni-deploy/docker [command]`

## variables notices

- `SHOW_TIP?=false` _default not show base tip, if you want show, pls set SHOW_TIP=true or others, but not empty._

## links

- [docker engine](https://docs.docker.com/engine/)
- [docker-compose](https://docs.docker.com/compose/)
- [docker hub](https://hub.docker.com/)

## examples

- **help**  `make -C uni-deploy/docker help`
- **env** `make -C uni-deploy/docker env`
- **cp-ignore** `make -C uni-deploy/docker cp-ignore` **pls rename it manually**
- **docker login** `make -C uni-deploy/docker login`
- **build image** `make -C uni-deploy/docker build DOCKER_FILE=<DOCKER_FILE> [REPOSITORY=<REPOSITORY>] [TAG=<TAG>]`
- **image tag** `make -C uni-deploy/docker tag IMAGE_ID=<image_id> [REPOSITORY=<REPOSITORY>] [TAG=<TAG>]`
- **push image** `make -C uni-deploy/docker push REPOSITORY=<REPOSITORY> [TAG=<TAG>]`
- ***list images** `make -C uni-deploy/docker list-image [IMAGE_LIST_PARAMS=<IMAGE_LIST_PARAMS>]`
- ***list containers** `make -C uni-deploy/docker list-docker [CONTAINER_LIST_PARAMS=<CONTAINER_LIST_PARAMS>]`
