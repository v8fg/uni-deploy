#!/usr/bin/env bash

# with map support, bash version shall >= 5.0+
set -e
set -o pipefail

[[ $DEBUG == true ]] && set -x

uni_deploy_repo=https://github.com/v8fg/uni-deploy.git
uni_deploy_branch=release
uni_deploy_path_name=uni-deploy
# only support current dir install
current_path_abs=$(pwd)
uni_deploy_install_path_abs="${current_path_abs}/${uni_deploy_path_name}"

# support branch name
declare -A -xr uni_deploy_branch_support=(["release"]="release" ["main"]="main" [dev]="dev")
readonly current_path_abs uni_deploy_repo uni_deploy_path_name uni_deploy_branch_support uni_deploy_install_path_abs

# https://git-scm.com/docs/git-rev-parse
# judge the dir whether is the git project or not, must contains .git, the project root dir
function is_git_project() {
    if [[ -d "$1/.git" ]]; then
        cd "$1/.git" && git rev-parse --is-inside-git-dir
        return 0
    else
        echo "false"
        return 0
    fi
}

# judge the git project remote url whether eq or not eq the specified url!
function exist_uni_deploy_url() {
    if [[ -d "$1" ]]; then
        cd "$1" && (git remote get-url --all origin | grep "$2" | grep -v grep)
        return 0
    else
        echo "false"
        return 0
    fi
}

# check the project root dir is a git project or not
_in_git_project=$(is_git_project "${current_path_abs}")

# must exec in the root dir of your project and with git cvs, if existed the same name dir, remove first.
if [[ "${_in_git_project}" == "true" ]]; then
    if [[ -d "${uni_deploy_install_path_abs}" ]]; then
        # stream shell, no use pipe deal, use func replae
        existed_uni_deploy_url=$(exist_uni_deploy_url "${uni_deploy_install_path_abs}" ${uni_deploy_repo})
        if [[ -n "${existed_uni_deploy_url}" ]]; then
            echo -e "\033[31malready installed，the install dir: \033[33m${uni_deploy_install_path_abs}\033[0m, pls uninstall first, if want reinstall it.\033[0m"
            exit 1
        else
            echo -e "\033[31mexisted the same dir: \033[33m${uni_deploy_path_name} in ${current_path_abs}\033[0m, pls remove first, if want install it.\033[0m"
            exit 1
        fi
    else
        echo -e "\033[32mwill install '${uni_deploy_path_name}' into the dir: \033[33m${uni_deploy_install_path_abs}\033[0m"
    fi
else
    echo -e "\033[31mthe dir: \033[33m${current_path_abs}\033[0m, is not existed or not a git project. pls install it into the project root dir with git.\033[0m"
    exit 1
fi

function init_branch() {
    if [[ -n "${1}" && -n "${uni_deploy_branch_support[${1}]}" ]];then
        uni_deploy_branch=${1}
    fi
}

# must init before install
init_branch "${1}"

function install() {
#    git submodule init  # can fixed: please make sure that the .gitmodules file is in the working tree.
    cd "${current_path_abs}" && \
    git submodule add --force -b "${uni_deploy_branch}" ${uni_deploy_repo} ${uni_deploy_path_name} && \
    git submodule update --init --recursive ${uni_deploy_path_name} &&
    echo -e "\033[32minstall submodule repo[${uni_deploy_repo}], branch[${uni_deploy_branch}], path[${uni_deploy_path_name}] success\033[0m"
}

install "${current_path_abs}"
