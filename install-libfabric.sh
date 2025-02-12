#!/usr/bin/env bash

echo "==> Building libfabric"
# Pulls the libfabric repository and checks out the pull request commit
cd ${HOME}
git clone https://github.com/patemotter/libfabric
cd ${HOME}/libfabric
if [ ! "$PULL_REQUEST_ID" = "None" ]; then
    git fetch origin +refs/pull/$PULL_REQUEST_ID/*:refs/remotes/origin/pr/$PULL_REQUEST_ID/*
    git checkout $PULL_REQUEST_REF -b PRBranch
fi
./autogen.sh
configure_flags=(--prefix=${HOME}/libfabric/install/ \
    --enable-debug  \
    --enable-mrail  \
    --enable-tcp    \
    --enable-rxm    \
    --disable-rxd   \
    --disable-verbs \
    --enable-efa )
# Build libfabric with cuda on x86_64 platform only.
if [ "$(uname -m)" == "x86_64" ]; then
    configure_flags+=(--with-cuda=/usr/local/cuda --enable-cuda-dlopen)
fi
./configure "${configure_flags[@]}"
make -j 4
make install
LIBFABRIC_INSTALL_PATH=${HOME}/libfabric/install
# ld.so.conf.d files are preferred in alphabetical order
# this doesn't seem to be working for non-interactive shells
sudo bash -c "echo ${LIBFABRIC_INSTALL_PATH} > /etc/ld.so.conf.d/aaaa-libfabric-testing.sh"
