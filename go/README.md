# uni-deploy go

## requirements

>pls ref: [go requirements](../README.md)

## usage

- `make help` _if already in the `uni-deploy/go`_
- `cd {PROJECT_ROOT}/uni-deploy/go && make [command]`
- `make -C {PROJECT_ROOT}/uni-deploy/go [command]`

## variables notices

- `SHOW_TIP?=false` _default not show base tip, if you want show, pls set SHOW_TIP=true or others, but not empty._
- `BUILD_DIR_OUT=${PROJECT_ROOT}/build`
- `binary_file=${BUILD_DIR_OUT}/bin/${BINARY_NAME}`
- `build_dir_out_binary=${BUILD_DIR_OUT}/bin`
- `build_dir_out_conf=${BUILD_DIR_OUT}/conf`
- `build_dir_out_coverage=${BUILD_DIR_OUT}/coverage`

## links

- [go link](https://pkg.go.dev/cmd/link)
- [golangci-lint](https://golangci-lint.run)

## examples

- **help**  `make -C uni-deploy/go help`
- **env** `make -C uni-deploy/go env`
- **list** `make -C uni-deploy/go list`
- **tidy** `make -C uni-deploy/go tidy`
- **vendor** `make -C uni-deploy/go vendor`
- **go-version** `make -C uni-deploy/go go-version`
- **fmt** `make -C uni-deploy/go fmt`
- **fmt-check-files** `make -C uni-deploy/go fmt-check-files`
- **build** `make -C uni-deploy/go build [BINARY_NAME=<BINARY_NAME>]`
- **release** `make -C uni-deploy/go release [BINARY_NAME=<BINARY_NAME>]`
- **release-vendor** `make -C uni-deploy/go release-vendor [BINARY_NAME=<BINARY_NAME>]`
- **list-build** `make -C uni-deploy/go list-build`
- **upx** `make -C uni-deploy/go upx [BINARY_NAME=<BINARY_NAME>]`
- **upx-bak** `make -C uni-deploy/go upx-bak`
- **version** `make -C uni-deploy/go version [BINARY_NAME=<BINARY_NAME>]`
- **run** `make -C uni-deploy/go run`
- **run-binary** `make -C uni-deploy/go run-binary [BINARY_NAME=<BINARY_NAME>]`
- **clean** `make -C uni-deploy/go clean`
- **clean-binary** `make -C uni-deploy/go clean-binary [BINARY_NAME=<BINARY_NAME>]`
- **clean-conf** `make -C uni-deploy/go clean-conf`
