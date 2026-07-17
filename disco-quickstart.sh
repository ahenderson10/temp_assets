#!/bin/sh
set -e

VER="${1:-3.1}"
COMP="${2:-NCOMP}"

cd ~   


if [ ! -f /usr/include/jpeglib.h ]; then
    (
        mkdir -p /tmp/build && cd /tmp/build
        wget --no-check-certificate https://ijg.org/files/jpegsrc.v9e.tar.gz
        tar xf jpegsrc.v9*.tar.gz
        cd jpeg-9*
        ./configure --prefix=/usr
        make -j"$(nproc || echo 2)"
        make install
        ldconfig
    )
fi


if [ ! -d ~/samples_V500_${COMP}_${VER} ]; then
    [ -f ~/samples_V500_${COMP}_${VER}.zip ] || \
        wget --no-check-certificate -P ~ \
        https://raw.githubusercontent.com/ahenderson10/temp_assets/refs/heads/main/samples_V500_NCOMP_3.1.zip
    unzip ~/samples_V500_${COMP}_${VER}.zip -d ~
fi


if [ ! -d ~/VectorBlox-SDK-release-v$VER ]; then
    [ -f ~/release-v$VER.zip ] || \
        wget --no-check-certificate -O ~/release-v$VER.zip \
        https://github.com/Microchip-Vectorblox/VectorBlox-SDK/archive/refs/tags/release-v$VER.zip
    unzip ~/release-v$VER.zip -d ~
fi

cd ~/VectorBlox-SDK-release-v$VER/example/soc-c

if [ ! -f run-model ]; then
    make clean
    make kit=discovery
    make overlay || true
fi

if [ -f run-model ]; then
    ./run-model ~/samples_V500_${COMP}_${VER}/mobilenet_v2_V500_ncomp.vnnx \
        ../../tutorials/test_images/oreo.jpg CLASSIFY
fi
