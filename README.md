# uni-deploy

Makefile and scripts for simply and uni dev-ops, current include go, docker

## feature

- [x] go
- [x] docker

## requirements

>**choose needed to install**

- **platform** `MacOS/Linux`
- [bash](https://www.gnu.org/software/bash/) **5.0+**
- [gnu-getopt](https://formulae.brew.sh/formula/gnu-getopt) *MacOS*
- [git](https://git-scm.com/) _2.34.1+_
- [make](https://www.gnu.org/software/make/) _3.81+_

### docker requirements

- [docker](https://github.com/docker) **20.10.5+**
- [docker-compose](https://github.com/docker/compose) _maybe_ **2.2.2+**

### go requirements

- [upx](https://github.com/upx/upx)
- [go](https://github.com/golang/go) **go1.17+**
- [binary version](https://github.com/xwi88/version) **for `-ldflags`**

## quick install

You can easily install by `install.sh`, **but** only support into the `root dir of your project`, default branch `release`.

>`release`

- `curl -sSfL https://raw.githubusercontent.com/v8fg/uni-deploy/release/install.sh | bash`
- `wget -O- -nv https://raw.githubusercontent.com/v8fg/uni-deploy/release/install.sh | bash`
- `wget -qO-  https://raw.githubusercontent.com/v8fg/uni-deploy/release/install.sh | bash`

>`specify branch: [release, main, dev]`

- `curl -sSfL https://raw.githubusercontent.com/v8fg/uni-deploy/release/install.sh | bash -s dev`
- `wget -O- -nv https://raw.githubusercontent.com/v8fg/uni-deploy/release/install.sh | bash -s dev`
- `base < (curl -sSfL https://raw.githubusercontent.com/v8fg/uni-deploy/release/install.sh) dev`
- `base < (wget -O- -nv https://raw.githubusercontent.com/v8fg/uni-deploy/release/install.sh) dev`

## standard install and other ops

>**better clone into your project root dir**

- `git clone https://github.com/v8fg/uni-deploy.git -b <branch> [path]`
- `bash all.sh -h`

>more usage: `bash all.sh -h`

## uninstall uni-deploy

- `bash uni-deploy/all.sh -c uninstall`
  - the submodule `uni-deploy` **must in the root dir for your project**
