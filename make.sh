#!/usr/bin/env bash

# with map support, bash version shall >= 5.0+
set -e
set -o pipefail

[[ $DEBUG == true ]] && set -x

uni_deploy_repo=https://github.com/v8fg/uni-deploy.git
uni_deploy_branch=release
uni_deploy_path_name=uni-deploy
readonly uni_deploy_repo uni_deploy_branch uni_deploy_path_name

# support branch name
declare -A -xr uni_deploy_branch_support=(["release"]="release" ["main"]="main" ["dev"]="dev")

CURRENT_PATH=$(cd $(dirname "$0"); pwd)
readonly CURRENT_PATH


SCRIPT_FILE=$(basename "$0")
echo "current script location: ${CURRENT_PATH}, filename:${SCRIPT_FILE}"

# receive abs path, install uni-deploy
_uni_deploy_path="./"


# input params: $1=command, $2=path
app_command=$1

function help_info() {
    echo "Available command options:"
    echo " install  [path]                      - install uni-deploy, shall to your project root dir"
    echo " status   [path]                      - uni-deploy module status"
    echo " update   [path]                      - uni-deploy module update"
    echo " delete   [path]                      - uni-deploy delete"
    echo " help                                 - displays the help"
    echo " [command]                            - Execute the specified command, eg. bash commands."
    echo -e "\033[31mAvailable params options\033[0m"
}

# init_dir init the install dir, abs path, better in your project root dir
function init_dir() {
    # shall be git project
    # warn: dirname will cut last /, so we append .git to _input_path
    _input_path=${1}/.git
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

function install() {
    init_dir "$1"

    _uni_deploy_branch=uni_deploy_branch
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

function status() {
    init_dir "$1"

    cd "${_uni_deploy_path}" && \
    git submodule --quiet status ${uni_deploy_path_name}
}

function update() {
    init_dir "$1"

    cd "${_uni_deploy_path}" && \
    git submodule --quiet update ${uni_deploy_path_name}
}

function sync() {
    init_dir "$1"

    cd "${_uni_deploy_path}" && \
    git submodule --quiet sync ${uni_deploy_path_name}
}

function delete() {
    init_dir "$1"

    cd "${_uni_deploy_path}" && \
    git submodule deinit -f ${uni_deploy_path_name} && git rm -f ${uni_deploy_path_name}
    
    cd "${_uni_deploy_path}" && rm -rf .git/modules/${uni_deploy_path_name}
    # git commit -am "remove the submodule ${uni_deploy_path_name}"
}


case ${app_command} in
    install|status|update|delete)
    case ${app_command} in
        install)
            shift 1
            install "$@"
            _info="exec install: install ${uni_deploy_path_name} done at:$(date "+%FT%T%z")"
            echo -e "\033[34m${_info}\033[0m"
        ;;
        status)
            shift 1
            status "$@"
            _info="exec status: status ${uni_deploy_path_name} done at:$(date "+%FT%T%z")"
            echo -e "\033[34m${_info}\033[0m"
        ;;
        update)
            shift 1
            update "$@"
            _info="exec update: update ${uni_deploy_path_name} done at:$(date "+%FT%T%z")"
            echo -e "\033[34m${_info}\033[0m"
        ;;
        sync)
            shift 1
            sync "$@"
            _info="exec sync: sync ${uni_deploy_path_name} done at:$(date "+%FT%T%z")"
            echo -e "\033[34m${_info}\033[0m"
        ;;
        delete)
            shift 1
            delete "$@"
            _info="exec delete: remove ${uni_deploy_path_name} done at:$(date "+%FT%T%z")"
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
