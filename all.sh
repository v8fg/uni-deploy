#!/usr/bin/env bash

# with map support, bash version shall >= 5.0+
set -e
set -o pipefail

[[ $DEBUG == true ]] && set -x

CURRENT_PATH=$(cd $(dirname "$0"); pwd)
# receive abs path, install uni-deploy
uni_deploy_path=$(cd "$CURRENT_PATH/../"; pwd)
uni_deploy_repo=https://github.com/v8fg/uni-deploy.git
uni_deploy_path_name=uni-deploy
uni_deploy_install_path_abs="${uni_deploy_path}/${uni_deploy_path_name}"

# uni_deploy_branch can choose in some commands
uni_deploy_branch=release

# support branch name
declare -A -xr uni_deploy_branch_support=(["release"]="release" ["main"]="main" ["dev"]="dev")
readonly CURRENT_PATH uni_deploy_path uni_deploy_repo uni_deploy_path_name uni_deploy_branch_support uni_deploy_install_path_abs

function usage() {
    echo -e "Usage: $0 [-c command] [-b branch] [-t tip] [-h help]"
}

function exit_abnormal() {
    usage
    exit 1
}

function help_info() {
    echo -e "$(usage)"
    echo -e "\n"
    echo -e "\033[31mAvailable command options:\033[0m"
    echo " install      [-b branch]                 - install uni-deploy, shall into your project root dir"
    echo " uninstall                                - uninstall uni-deploy, shall execute in project root dir"
    echo " submodule                                - module info for your project"
    echo " switch       [-b branch]                 - switch uni-deploy module branch, shall execute in project root dir"
    echo " status                                   - uni-deploy module, status"
    echo " diff                                     - uni-deploy module, diff"
    echo " update                                   - uni-deploy module, update --remote"
    echo " sync                                     - uni-deploy module, sync and init"
    echo " log                                      - uni-deploy module, the latest 10 log records"
    echo " help                                     - displays the help"
}

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

_in_git_project=$(is_git_project "${uni_deploy_path}")

# must git project
if [[ "${_in_git_project}" == "false" ]]; then
    _str_info="must install 'uni-deploy' into the root dir of the project with git at first, the current root dir invalid: \033[31m${uni_deploy_path}\033[0m"
    echo -e "\033[33m${_str_info}\033[0m"
    exit 1
fi

# pls watch the param $3
function init_branch() {
    if [[ -n "${1}" && -n "${uni_deploy_branch_support[${1}]}" ]];then
        uni_deploy_branch=${1}
    fi
}

# Define list of arguments expected in the input
opt_string="c:b:th"

function parse_args() {
    if [[ $# -eq 0 ]]; then
        exit_abnormal
        exit 1
    fi

    while getopts "${opt_string}" option; do
        case "${option}" in
            c)
                app_command=${OPTARG}
                ;;
            b)
                init_branch "${OPTARG}"
                ;;
            t)
                show_tip=true
                ;;
            h)
                help_info
                ;;
            *)
                exit_abnormal
                ;;
        esac
    done
    shift "$((OPTIND-1))"
}
# parse args and init the inner variables
parse_args "$@"

if [[ "${show_tip}" == "true" ]]; then
    echo -e "[tip] the root dir of your project: ${uni_deploy_path}"
    echo -e "[tip] script location: ${CURRENT_PATH}, filename: $(basename "$0")"
fi

function install() {
    echo -e "uni_deploy_path: $uni_deploy_path"
    if [[ "${_in_git_project}" == "true" ]]; then
        if [[ -d "${uni_deploy_path}" ]]; then
            exist_uni_deploy_url=$(cd "${uni_deploy_install_path_abs}"; git remote get-url --all origin | grep "${uni_deploy_repo}" | grep -v grep)
            if [[ -n "${exist_uni_deploy_url}" ]]; then
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

    cd "${uni_deploy_path}" && \
    git submodule --quiet add --force -b "${uni_deploy_branch}" ${uni_deploy_repo} ${uni_deploy_path_name}
}

function switch() {
    cd "${uni_deploy_path}" && \
    git submodule set-branch --branch "${uni_deploy_branch}" ${uni_deploy_path_name} && \
    cd "${uni_deploy_path}/${uni_deploy_path_name}" && git checkout "${uni_deploy_branch}"
}

function uninstall() {
    cd "${uni_deploy_path}" && git submodule deinit -f ${uni_deploy_path_name}
    cd "${uni_deploy_path}" && git rm -f ${uni_deploy_path_name}
    cd "${uni_deploy_path}" && rm -rf .git/modules/${uni_deploy_path_name}
    # cd "${uni_deploy_path}" && git commit -am "remove the submodule ${uni_deploy_path_name}"
}

function status() {
    cd "${uni_deploy_path}" && \
    git submodule --quiet status ${uni_deploy_path_name}
}


function diff() {
    cd "${uni_deploy_path}" && \
    git diff --submodule ${uni_deploy_path_name}
}


function update() {
    cd "${uni_deploy_path}" && \
    git submodule foreach git pull
    # git submodule update --remote --rebase ${uni_deploy_path_name}
    # git submodule update --remote --merge ${uni_deploy_path_name}
    # if detached HEAD, remote target branch is ahead of your local target
}

function sync() {
    cd "${uni_deploy_path}" && \
    git submodule sync --recursive ${uni_deploy_path_name}
}

function log() {
    cd "${uni_deploy_path}/${uni_deploy_path_name}" && \
    git log -10 --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset | %C(red)%cs%Creset' --abbrev-commit
}

case ${app_command} in
    install|uninstall|submodule|status|diff|update|sync|switch|log)
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
        submodule)
            shift 1
            submodule
            _info="exec submodule: [module=${uni_deploy_path_name}] done at:$(date "+%FT%T%z")"
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
        help_info
    ;;
esac
