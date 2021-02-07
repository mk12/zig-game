#!/bin/bash

set -eufo pipefail

readonly deps=(glfw bgfx bx bimg)

readonly glfw_ref=3.3.2
readonly glfw_url="https://github.com/glfw/glfw/archive/$glfw_ref.tar.gz"

readonly bgfx_ref=eee065c59fa8d8a31211ef41bf3f890f608f8d63
readonly bgfx_url="https://github.com/bkaradzic/bgfx/archive/$bgfx_ref.tar.gz"

readonly bx_ref=99d4cb78adec680bd56396be300ed30439da8f26
readonly bx_url="https://github.com/bkaradzic/bx/archive/$bx_ref.tar.gz"

readonly bimg_ref=c779a67d6041c289f147a732c225fa78635a09a3
readonly bimg_url="https://github.com/bkaradzic/bimg/archive/$bimg_ref.tar.gz"

usage() {
    cat <<EOS
usage: $0 [--help]

Downloads Furious Fowls build dependencies.
EOS
}

main() {
    cd "$(dirname "$0")"
    mkdir -p deps
    cd deps
    for d in "${deps[@]}"; do
        if [[ -d "$d" ]]; then
            echo "$d already downloaded"
        else
            url_var="${d}_url"
            read -rp "download $d (${!url_var})? [y/N] "
            case $REPLY in
                y|Y) "download_$d" ;;
            esac
        fi
    done
}

download_glfw() {
    curl -L "$glfw_url" | tar xvz glfw-$glfw_ref/{LICENSE.md,include,src}
    mv glfw{-$glfw_ref,}
}

download_bgfx() {
    curl -L "$bgfx_url" \
        | tar xvz bgfx-$bgfx_ref/{LICENSE,include,src,3rdparty/renderdoc}
    mv bgfx{-$bgfx_ref,}
}

download_bx() {
    curl -L "$bx_url" | tar xvz bx-$bx_ref/{LICENSE,include,src,3rdparty}
    mv bx{-$bx_ref,}
}

download_bimg() {
    curl -L "$bimg_url" | tar xvz bimg-$bimg_ref/{LICENSE,include,src,3rdparty}
    mv bimg{-$bimg_ref,}
}

if [[ $# -eq 0 ]]; then
    main
else
    case $1 in
        -h|--help) usage ;;
        *) usage >&2; exit 1 ;;
    esac
fi
