#!/usr/bin/env bash

# with map support, bash version shall >= 5.0+
set -e
set -o pipefail

[[ $DEBUG == true ]] && set -x

uni_deploy_repo=https://github.com/v8fg/uni-deploy.git
uni_deploy_branch=release
# only support current dir install
uni_deploy_path="./"
uni_deploy_path_name=uni-deploy
# support branch name
declare -A -xr uni_deploy_branch_support=(["release"]="release" ["main"]="main" [dev]="dev")
readonly uni_deploy_repo uni_deploy_path uni_deploy_path_name uni_deploy_branch_support

# must exec in the root dir for your project and with git cvs
if [[ -d "${uni_deploy_path}/${uni_deploy_path_name}" ]]; then 
    exist_uni_deploy_url=$(cd "${uni_deploy_path}/${uni_deploy_path_name}"; git remote get-url --all origin | grep "${uni_deploy_path_name}" | grep -v grep)

    if [[ -n "${exist_uni_deploy_url}" ]]; then
        echo -e "\033[31malready installed or existed the same name dir: \033[33m${uni_deploy_path_name}\033[0m, pls check or fixed it\033[0m"
        exit 1
    fi
fi


function init_branch() {
    if [[ -n "${1}" && -n "${uni_deploy_branch_support[${1}]}" ]];then
        uni_deploy_branch=${1}
    fi
}

# must init before install
init_branch "${1}"

function install() {
    cd "${uni_deploy_path}" && \
    git submodule add --force -b "${uni_deploy_branch}" ${uni_deploy_repo} ${uni_deploy_path_name}
    echo -e "\033[32minstall submodule repo[${uni_deploy_repo}], branch[${uni_deploy_branch}], path[${uni_deploy_path_name}] success\033[0m"
}

install "${uni_deploy_path}"
