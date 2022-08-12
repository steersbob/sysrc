#! /bin/bash
#
# To load on shell start, run install_env.sh

# Generic
alias gimme="sudo apt update && sudo apt dist-upgrade && sudo apt autoremove"
alias updown="gimme; echo 'sleepy...'; sleep 5; sudo shutdown now"
alias upboot="gimme; echo 'booty!'; sleep 5; sudo reboot"
alias where="which"
alias selkey="xclip -sel clip < ~/.ssh/id_rsa.pub"
alias vg="rg --vimgrep"
alias ccode="devcontainer open"

function assume-yes() {
    echo 'APT::Get::Assume-Yes "true";' | sudo tee /etc/apt/apt.conf.d/90assumeyes
}

function farshark() {
    echo "Opening interface $2 on $1"
    sudo echo ""
    ssh "$1" sudo tcpdump -i "$2" -U -s0 -w - 'not port 22' | sudo wireshark -k -i -
}

function simcat() {
    port="${1:-8332}"
    socat "tcp-listen:$port,bind=172.17.0.1,fork tcp:127.0.0.1:$port"
}

# Docker
alias dk='docker'
alias dkc='docker-compose'
alias follow="docker-compose logs --follow"
alias recompose="docker-compose down && docker-compose up -d"
alias dknew='docker-compose up -d --force-recreate'

function prepx() {
    # Early exit if current builder can handle ARM builds
    if [[ $(docker buildx inspect | grep 'linux/arm/v7') != '' ]]; then
        return
    fi
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    docker buildx rm bricklayer || true
    docker buildx create --use --name bricklayer
    docker buildx inspect --bootstrap
}

function pullup() {
    # shellcheck disable=SC2068
    dkc pull $@ && dkc up -d $@
}

# virtualenv
alias shellac=". ./.venv/bin/activate"

# Git
alias prettygit="git log --oneline --decorate --all --graph"
alias fetchap="git fetch --all -p"
alias rootd='cd "$(git rev-parse --show-toplevel)"'

function prunel() {
    # Removes all local branches that do not have a counterpart on 'origin' or 'upstream'
    # Careful: don't run this when current branch has no remote
    git branch -vv | grep 'origin/.*: gone]\|upstream/.*: gone]' | awk '{print $1}' | xargs -r git branch -d
}

function synchel() {
    fetchap && git pull && prunel
}

function synchout() {
    fetchap &&
        git checkout "$1" &&
        git pull &&
        git submodule update &&
        prunel
}

function pushpr() {
    gh pr create -R "BrewBlox/$(basename "$(git rev-parse --show-toplevel)")"
}

function addrepo() { (
    set -ex
    cd ~/git
    git clone git@github.com:steersbob/"$1".git
    cd "$1"
    git remote add upstream git@github.com:BrewBlox/"$1".git
    git fetch --all
    git checkout -B develop --track upstream/develop
    git checkout -B edge --track upstream/edge
    git checkout develop
); }

# ESP32 development

alias dotdf="source ~/esp/esp-idf/export.sh"
alias idf='idf.py'

function esp_flash() {
    docker run \
        -it --rm --privileged \
        --pull always \
        -v /dev:/dev \
        --entrypoint bash \
        -w /app/firmware \
        brewblox/brewblox-devcon-spark:"${1:-"develop"}" \
        flash
}
