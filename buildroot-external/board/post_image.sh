#!/usr/bin/env bash
set -e

xz --compress --force --keep --suffix=.lz --verbose "${1}"/rootfs.cpio
