#!/bin/sh
go_base="/home/nelhage/sw/go"

if [ -d "$go_base" ]; then
    : ${GO_VERSION:=$(readlink "$go_base/default")}
    export GOROOT="$go_base/$GO_VERSION"
fi
if ! [ "$GOROOT" ]; then
    export GOROOT=/usr/local/go/
fi

exec "$GOROOT/bin/$(basename "$0")" "$@"
