#!/usr/bin/env bash

# with map support, bash version shall >= 5.0+
set -e
set -o pipefail

[[ $DEBUG == true ]] && set -x

uni_deploy_repo=https://github.com/v8fg/uni-deploy.git
uni_deploy_branch=release
uni_deploy_path_name=uni-deploy
readonly uni_deploy_repo uni_deploy_path_name

# support branch name
declare -A -xr uni_deploy_branch_support=(["release"]="release" ["main"]="main" ["dev"]="dev")

CURRENT_PATH=$(cd $(dirname "$0"); pwd)
readonly CURRENT_PATH

SCRIPT_FILE=$(basename "$0")

# receive abs path, install uni-deploy
_uni_deploy_path=$(cd "$CURRENT_PATH/../"; pwd)
echo -e "[init] current script location: ${CURRENT_PATH}, filename:${SCRIPT_FILE}"

# input params: $1=command, $2=path
app_command=$1

# init_dir init the install dir, abs path, better in your project root dir
function init_dir() {
    # shall be git project
    # warn: dirname will cut last /, so we append .git to _input_path
    _input_path=${_uni_deploy_path}/.git
    if [[ -n "${1}" ]]; then
        _input_path=${1}/.git
    fi
    _input_path_dirname=$(dirname "${_input_path}")

    if [[ -n "${_input_path_dirname}" &&  -d "${_input_path_dirname}" ]]; then
        _uni_deploy_path=$(cd "${_input_path_dirname}"; pwd)
        return 0
    else
        _str_info="install invalid dir: ${_input_path_dirname}"
        echo -e "\033[31m${_str_info}\033[0m"
        return 1
    fi
}

# pls watch the param $3
function init_branch() {
    if [[ -n "${1}" && -n "${uni_deploy_branch_support[${1}]}" ]];then
        uni_deploy_branch=${1}
    fi
}

# init install dir. $1=command, $2=[path]; $3=[branch]
init_dir "${2}"

# init branch
init_branch "${3}" 


echo -e "[init] default install:${_uni_deploy_path}, specify install:${_uni_deploy_path}"

function help_info() {
    echo "Available command options:"
    echo " install      [path]  [branch]            - install uni-deploy, shall into your project root dir"
    echo " uninstall    [path]                      - uninstall uni-deploy, pls watch your path, shall execute in project root dir"
    echo " switch       [path]  [branch]            - switch uni-deploy brranch, shall execute in project root dir"
    echo " status       [path]                      - uni-deploy module status"
    echo " diff         [path]                      - uni-deploy module diff"
    echo " update       [path]                      - uni-deploy module update --remote"
    echo " sync         [path]                      - uni-deploy module sync and init"
    echo " log          [path]                      - uni-deploy module latest 10 log records"
    echo " help                                     - displays the help"
    echo " [command]                                - Execute the specified command, eg. bash commands."
    echo -e "\033[31mAvailable params options\033[0m"
}

function install() {
    # must not install again if installed
    _exist_uni_deploy_url=$(cd "${_uni_deploy_path}/${uni_deploy_path_name}"; git remote get-url --all origin | grep "${uni_deploy_path_name}" | grep -v grep)
    if [[ -n "${_exist_uni_deploy_url}" ]]; then
        echo -e "\033[31malready installed or existed the same name dir: \033[33m${uni_deploy_path_name}\033[0m, pls check or fixed it\033[0m"
        exit 1
    fi

    _uni_deploy_branch=${uni_deploy_branch}
    if [[ -n "$2" ]]; then
        if [[ -z "${uni_deploy_branch_support[${2}]}"  ]];then
            _str_info="install uni_deploy_branch_support(${1}) error, shall in [${!uni_deploy_branch_support[*]}]"
            echo -e "\033[31m${_str_info}\033[0m"
            exit 1
        else
            _uni_deploy_branch=${uni_deploy_branch_support[${2}]}
        fi
    fi

    cd "${_uni_deploy_path}" && \
    git submodule --quiet add --force -b "${_uni_deploy_branch}" ${uni_deploy_repo} ${uni_deploy_path_name}
}

function switch() {
    cd "${_uni_deploy_path}" && \
    git submodule set-branch --branch "${uni_deploy_branch}" ${uni_deploy_path_name}
}

function uninstall() {
    cd "${_uni_deploy_path}" && git submodule deinit -f ${uni_deploy_path_name} 
    cd "${_uni_deploy_path}" && rm -rf .git/modules/${uni_deploy_path_name}
    cd "${_uni_deploy_path}" && git rm -f ${uni_deploy_path_name}
    # cd "${_uni_deploy_path}" && git commit -am "remove the submodule ${uni_deploy_path_name}"
}

function status() {
    cd "${_uni_deploy_path}" && \
    git submodule --quiet status ${uni_deploy_path_name}
}


function diff() {
    cd "${_uni_deploy_path}" && \
    git diff --submodule ${uni_deploy_path_name}
}


function update() {
    cd "${_uni_deploy_path}" && \
    git submodule foreach git pull
    # git submodule update --remote --rebase ${uni_deploy_path_name}
    # git submodule update --remote --merge ${uni_deploy_path_name}
    # if detached HEAD, remote target branch is ahead of your local target
}

function sync() {
    cd "${_uni_deploy_path}" && \
    git submodule sync --recursive ${uni_deploy_path_name}
}

function log() {
    cd "${_uni_deploy_path}/${uni_deploy_path_name}" && \
    git log -10 --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset | %C(red)%cs%Creset' --abbrev-commit
}

case ${app_command} in
    install|uninstall|status|diff|update|sync|switch|log)
    case ${app_command} in
        install)
            shift 1
            install "$@"
            _info="exec install: [module=${uni_deploy_path_name}, branch=${uni_deploy_branch}] done at:$(date "+%FT%T%z")"
            echo -e "\033[34m${_info}\033[0m"
        ;;
        uninstall)
            shift 1
            uninstall "$@"
            _info="exec uninstall: [module=${uni_deploy_path_name}] done at:$(date "+%FT%T%z")"
            echo -e "\033[34m${_info}\033[0m"
        ;;
        status)
            shift 1
            status "$@"
            _info="exec status: [module=${uni_deploy_path_name}] done at:$(date "+%FT%T%z")"
            echo -e "\033[34m${_info}\033[0m"
        ;;
        diff)
            shift 1
            status "$@"
            _info="exec diff: [module=${uni_deploy_path_name}] done at:$(date "+%FT%T%z")"
            echo -e "\033[34m${_info}\033[0m"
        ;;
        update)
            shift 1
            update "$@"
            _info="exec update: [module=${uni_deploy_path_name}] done at:$(date "+%FT%T%z")"
            echo -e "\033[34m${_info}\033[0m"
        ;;
        sync)
            shift 1
            sync "$@"
            _info="exec sync: [module=${uni_deploy_path_name}] done at:$(date "+%FT%T%z")"
            echo -e "\033[34m${_info}\033[0m"
        ;;
        switch)
            shift 1
            switch "$@"
            _info="exec switch: [module=${uni_deploy_path_name}, branch=${uni_deploy_branch}] done at:$(date "+%FT%T%z")"
            echo -e "\033[34m${_info}\033[0m"
        ;;
        log)
            shift 1
            log "$@"
            _info="exec log: [module=${uni_deploy_path_name}] done at:$(date "+%FT%T%z")"
            echo -e "\033[34m${_info}\033[0m"
    ;;
    esac
    ;;
    help)
        help_info
    ;;
     *)
        # first input empty, output help info
        if [[ -z "$1" ]]; then
            help_info
        else
            # exec any ops, shall watch out!
            exec "$@"
        fi
    ;;
esac
