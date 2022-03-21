#!/usr/bin/env bash

# with map support, bash version shall >= 5.0+
set -e
set -o pipefail

[[ $DEBUG == true ]] && set -x

uni_deploy_repo=https://github.com/v8fg/uni-deploy.git
uni_deploy_branch=release
uni_deploy_path="./"
uni_deploy_path_name=uni-deploy
readonly uni_deploy_repo uni_deploy_branch uni_deploy_path uni_deploy_path_name

function install() {
    cd "${uni_deploy_path}" && \
    git submodule --quiet add --force -b ${uni_deploy_branch} ${uni_deploy_repo} ${uni_deploy_path_name}
    echo -e "\033[31minstall submodule repo:${uni_deploy_repo}, branch=${uni_deploy_branch} success\033[0m"
}

install "${uni_deploy_path}"
