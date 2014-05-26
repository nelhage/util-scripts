#!/bin/sh
go_base="/home/nelhage/sw/go"

: ${GO_VERSION:=$(readlink "$go_base/default")}
export GOROOT="$go_base/$GO_VERSION"

exec "$go_base/$GO_VERSION/bin/$(basename "$0")" "$@"
