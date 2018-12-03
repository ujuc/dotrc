#!/usr/bin/env bash

#############################
#   System Setting          #
#   Sungjin (ujuc@ujuc.kr)  #
#   Version : 2.0           #
#############################

BASE=$(pwd)

function setting_mac() {
    # configure xcode
    xcode-select --install
    sudo xcodebuild -license

    # install brew
    [ -z "$(witch brew)" ] && \
        /usr/bin/ruby -e \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

}

function setting_ubuntu() {

}

function setting_redhat() {

}

function setting_arch() {

}

function bootstrap() {
    # os check
    if [[ "$OSTYPE" == "darwin"* ]]; then
        setting_mac
    elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        name=`cat /etc/*-release | grep '_ID'`

        if [[ "$name" == *"Ubuntu"* ]]; then
            setting_ubuntu
        else
            echo "Not checked"
        fi
    else
        echo "Not checked"
    fi
}

bootstrap

#/* vim: noai:ts=4:sw=4
